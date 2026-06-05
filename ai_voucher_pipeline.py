"""
╔══════════════════════════════════════════════════════════════════════════════╗
║          AI VOUCHER PIPELINE — DakLak Agricultural E-Commerce              ║
║          Project: daklakagent (Firebase)                                   ║
║          Author : Autonomous AI Data & Growth Agent                        ║
║          Window : Last 30 Days                                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

SETUP
-----
1. Install dependencies:
       pip install firebase-admin

2. Download your Firebase service-account key from:
       Firebase Console → Project Settings → Service Accounts
       → Generate new private key  →  save as  serviceAccountKey.json
   Place it beside this script (or update SERVICE_ACCOUNT_PATH below).

3. Run:
       python ai_voucher_pipeline.py
"""

# ─────────────────────────────── imports ────────────────────────────────────
import json
import uuid
import random
import string
import logging
import sys
from datetime import datetime, timedelta, timezone
from typing import Optional

# Force UTF-8 stdout so emoji in log/print don't crash on Windows cp1252
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

import firebase_admin
from firebase_admin import credentials, firestore

# ─────────────────────────────── config ─────────────────────────────────────
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"   # ← path to your key file

# ── Thresholds (small-scale system) ─────────────────────────────────────────
LOW_VIEWS      = 100        # < LOW_VIEWS  → low traffic
HIGH_VIEWS     = 100        # >= HIGH_VIEWS → high traffic
LOW_ORDERS     = 10         # < LOW_ORDERS  → low orders
GOOD_ORDERS    = 10         # >= GOOD_ORDERS → good orders
LOW_REVENUE    = 5_000_000  # < 5 000 000 VND → low revenue
MIN_RATING     = 4.0        # voucher eligibility floor

# ── Voucher config ───────────────────────────────────────────────────────────
VOUCHER_EXPIRY_DAYS    = 30
DEEP_DISCOUNT_MIN      = 0.30   # 30 %
DEEP_DISCOUNT_MAX      = 0.40   # 40 %
UPSELL_DISCOUNT        = 0.15   # 15 %
UPSELL_MIN_ORDER_VALUE = 500_000  # VND

# ─────────────────────────── logging setup ──────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("ai_voucher_pipeline")

# ─────────────────────── Firebase initialisation ────────────────────────────

def init_firebase() -> firestore.client:
    """Initialise the Firebase Admin SDK and return a Firestore client."""
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    log.info("Firebase initialised  (project: daklakagent)")
    return db


# ═══════════════════════════════════════════════════════════════════════════
#  STEP 1 — AGGREGATE METRICS  (last 30 days)
# ═══════════════════════════════════════════════════════════════════════════

def get_seller_metrics(db: firestore.client) -> dict:
    """
    Read products, orders, and users collections.
    Return a dict keyed by sellerId with aggregated metrics.

    Time filter: orders.createdAt >= now − 30 days
    """
    now           = datetime.now(timezone.utc)
    thirty_days_ago = now - timedelta(days=30)

    log.info("Fetching data for the window: %s  →  %s",
             thirty_days_ago.strftime("%Y-%m-%d"),
             now.strftime("%Y-%m-%d"))

    seller_data: dict = {}   # sellerId → metrics dict
    product_seller_map: dict = {}  # productId → sellerId  (for order fallback)

    # ── 1a. Products (viewCount) ─────────────────────────────────────────
    log.info("Querying 'products' collection …")
    products_ref = db.collection("products")
    for doc in products_ref.stream():
        p = doc.to_dict()
        # Seller info is nested: p["seller"]["id"]  (fallback: root "sellerId")
        seller_map = p.get("seller") or {}
        sid = (
            seller_map.get("id")
            or p.get("sellerId")
        )
        if not sid:
            log.debug("  Product %s has no sellerId — skipping.", doc.id)
            continue
        # Cache product → seller mapping for use in the orders loop
        product_seller_map[doc.id] = sid
        seller_data.setdefault(sid, _empty_metrics())
        seller_data[sid]["totalViews"] += int(p.get("viewCount", 0))

    # ── 1b. Orders (last 30 days) ────────────────────────────────────────
    log.info("Querying 'orders' collection (last 30 days) …")
    orders_ref = (
        db.collection("orders")
          .where(filter=firestore.FieldFilter("createdAt", ">=", thirty_days_ago))
    )
    for doc in orders_ref.stream():
        o = doc.to_dict()
        sid = o.get("sellerId")

        # Skip the stale "unknown" sentinel written before the checkout fix
        if sid == "unknown":
            log.debug("  Order %s has stale sellerId='unknown' — skipping. Run cleanup script.", doc.id)
            continue

        # Fallback: orders created by the admin dialog (before the sellerId fix)
        # have no sellerId. Resolve it via items[0].productId using our cache.
        if not sid:
            items = o.get("items") or []
            product_id = items[0].get("productId") if items else None
            if product_id:
                sid = product_seller_map.get(product_id)
                if sid:
                    log.debug("  Order %s: resolved sellerId=%s via productId=%s",
                              doc.id, sid, product_id)
                else:
                    log.debug("  Order %s: productId=%s not in seller cache — skipping.",
                              doc.id, product_id)
            if not sid:
                continue

        seller_data.setdefault(sid, _empty_metrics())
        seller_data[sid]["totalOrders"] += 1
        seller_data[sid]["revenue"]     += float(o.get("totalAmount", 0))

    # ── 1c. Users (rating & displayName) ──────────────────────────────────
    log.info("Querying 'users' collection …")
    users_ref = db.collection("users")
    for doc in users_ref.stream():
        u   = doc.to_dict()
        sid = u.get("sellerId") or doc.id   # fallback: doc ID is the sellerId
        if sid not in seller_data:
            continue
        seller_data[sid]["rating"]     = float(u.get("rating", 0.0))
        seller_data[sid]["sellerName"] = u.get("displayName") or u.get("name") or "Anonymous Seller"

    # ── 1d. Derived metrics ──────────────────────────────────────────────
    for sid, m in seller_data.items():
        orders = m["totalOrders"]
        views  = m["totalViews"]
        m["conversionRate"] = (orders / views) if views > 0 else 0.0
        m["AOV"]            = (m["revenue"] / orders) if orders > 0 else 0.0

    log.info("Metrics aggregated for %d sellers.", len(seller_data))
    return seller_data


def _empty_metrics() -> dict:
    return {
        "totalViews"     : 0,
        "totalOrders"    : 0,
        "revenue"        : 0.0,
        "conversionRate" : 0.0,
        "AOV"            : 0.0,
        "rating"         : 0.0,
        "sellerName"     : "Anonymous Seller",
    }


# ═══════════════════════════════════════════════════════════════════════════
#  STEP 2 — CLASSIFY SELLERS
# ═══════════════════════════════════════════════════════════════════════════

def classify_seller(metrics: dict) -> str:
    """
    Return one of: DEAD_SELLER | LOW_TRAFFIC | LOW_CONVERSION | LOW_REVENUE | HEALTHY
    Priority: DEAD_SELLER first (most severe), then specific problems.
    """
    views   = metrics["totalViews"]
    orders  = metrics["totalOrders"]
    revenue = metrics["revenue"]

    low_views   = views   < LOW_VIEWS
    high_views  = views   >= HIGH_VIEWS
    low_orders  = orders  < LOW_ORDERS
    good_orders = orders  >= GOOD_ORDERS
    low_revenue = revenue < LOW_REVENUE

    # DEAD_SELLER: nothing is working
    if low_views and low_orders and low_revenue:
        return "DEAD_SELLER"

    # LOW_TRAFFIC: barely any eyeballs and barely any orders
    if low_views and low_orders:
        return "LOW_TRAFFIC"

    # LOW_CONVERSION: lots of views but nobody buys
    if high_views and low_orders:
        return "LOW_CONVERSION"

    # LOW_REVENUE: orders are coming in but basket is small
    if good_orders and low_revenue:
        return "LOW_REVENUE"

    return "HEALTHY"


# ═══════════════════════════════════════════════════════════════════════════
#  STEP 3 — DUPLICATE PREVENTION
# ═══════════════════════════════════════════════════════════════════════════

def check_existing_voucher(db: firestore.client, seller_id: str,
                           voucher_type: str) -> bool:
    """
    Return True if an active, non-expired voucher of this type already exists.
    A match requires:
        sellerId == seller_id
        type     == voucher_type
        isActive == True
        expiryDate > now (UTC)
    """
    now = datetime.now(timezone.utc)
    query = (
        db.collection("vouchers")
          .where(filter=firestore.FieldFilter("sellerId",  "==", seller_id))
          .where(filter=firestore.FieldFilter("type",      "==", voucher_type))
          .where(filter=firestore.FieldFilter("isActive",  "==", True))
          .where(filter=firestore.FieldFilter("expiryDate", ">", now))
          .limit(1)
    )
    docs = list(query.stream())
    return len(docs) > 0


# ═══════════════════════════════════════════════════════════════════════════
#  STEP 4 — CREATE VOUCHER
# ═══════════════════════════════════════════════════════════════════════════

def _random_code(prefix: str = "AI", length: int = 6) -> str:
    chars = string.ascii_uppercase + string.digits
    return f"{prefix}-{''.join(random.choices(chars, k=length))}"


def create_voucher(db: firestore.client, seller_id: str,
                   seller_name: str,
                   voucher_type: str, discount: float,
                   min_order_value: float = 0.0) -> dict:
    """
    Write a new voucher document to Firestore and return its data dict.
    Field names mirror the existing Flutter schema in promotions_screen.dart:
        code, discountType, value, minOrderValue, expiryDate,
        isActive, sellerId, type, usageCount, usageLimit, createdAt
    """
    now    = datetime.now(timezone.utc)
    expiry = now + timedelta(days=VOUCHER_EXPIRY_DAYS)

    # Human-readable percentage value (e.g. 0.35 → 35)
    value_pct = round(discount * 100, 2)

    doc_data = {
        "sellerId"      : seller_id,
        "sellerName"    : seller_name,           # Denormalized
        "type"          : voucher_type,          # "DEEP_DISCOUNT" | "UPSELL"
        "code"          : _random_code(voucher_type[:2]),
        "discountType"  : "Percentage",
        "value"         : value_pct,             # stored as 35, not 0.35
        "minOrderValue" : min_order_value,
        "expiryDate"    : expiry,
        "isActive"      : True,
        "usageCount"    : 0,
        "usageLimit"    : 100,                   # sensible default
        "createdAt"     : now,
        "createdBy"     : "AI_VOUCHER_PIPELINE",
    }

    doc_ref = db.collection("vouchers").document()   # auto-generated ID
    doc_ref.set(doc_data)
    log.info("  ✅  Voucher created  id=%s  seller=%s  type=%s  discount=%.0f%%",
             doc_ref.id, seller_id, voucher_type, value_pct)
    return {**doc_data, "voucherId": doc_ref.id}


# ═══════════════════════════════════════════════════════════════════════════
#  STEP 5 — UPDATE SELLER TIER
# ═══════════════════════════════════════════════════════════════════════════

def update_seller_tier(db: firestore.client, seller_id: str, group: str) -> None:
    """
    Stamp the classification tier on the users document so the Flutter
    admin dashboard can surface it without re-running analytics.
    """
    users_ref = db.collection("users")

    # Try to find by sellerId field first
    query = users_ref.where(filter=firestore.FieldFilter("sellerId", "==", seller_id)).limit(1)
    docs  = list(query.stream())

    if docs:
        docs[0].reference.update({
            "sellerTier"         : group,
            "tierLastUpdatedAt"  : datetime.now(timezone.utc),
            "tierUpdatedBy"      : "AI_VOUCHER_PIPELINE",
        })
    else:
        # Fallback: the sellerId IS the document ID
        user_doc = users_ref.document(seller_id).get()
        if user_doc.exists:
            users_ref.document(seller_id).update({
                "sellerTier"        : group,
                "tierLastUpdatedAt" : datetime.now(timezone.utc),
                "tierUpdatedBy"     : "AI_VOUCHER_PIPELINE",
            })
        else:
            log.warning("  ⚠️  Could not find users document for sellerId=%s", seller_id)


# ═══════════════════════════════════════════════════════════════════════════
#  MAIN PIPELINE
# ═══════════════════════════════════════════════════════════════════════════

def run_pipeline() -> dict:
    """Execute the full pipeline and return a structured JSON report."""

    db = init_firebase()

    # ── Counters ─────────────────────────────────────────────────────────
    summary = {
        "totalSellers"   : 0,
        "lowTraffic"     : 0,
        "lowConversion"  : 0,
        "lowRevenue"     : 0,
        "deadSeller"     : 0,
        "healthy"        : 0,
    }
    vouchers_created      = 0
    duplicates_prevented  = 0
    details: list         = []

    # ── Aggregate ────────────────────────────────────────────────────────
    seller_metrics = get_seller_metrics(db)
    summary["totalSellers"] = len(seller_metrics)
    log.info("=" * 70)
    log.info("Processing %d sellers …", summary["totalSellers"])
    log.info("=" * 70)

    for seller_id, metrics in seller_metrics.items():
        group  = classify_seller(metrics)
        rating = metrics["rating"]

        log.info(
            "Seller %-28s | views=%4d | orders=%3d | revenue=%12.0f | "
            "rating=%.1f | group=%s",
            seller_id,
            metrics["totalViews"],
            metrics["totalOrders"],
            metrics["revenue"],
            rating,
            group,
        )

        # ── Tally group ───────────────────────────────────────────────
        if   group == "LOW_TRAFFIC"    : summary["lowTraffic"]    += 1
        elif group == "LOW_CONVERSION" : summary["lowConversion"]  += 1
        elif group == "LOW_REVENUE"    : summary["lowRevenue"]     += 1
        elif group == "DEAD_SELLER"    : summary["deadSeller"]     += 1
        else                           : summary["healthy"]        += 1

        # ── Decision logic ────────────────────────────────────────────
        action   = "NO_ACTION"
        discount = None
        voucher_type = None

        if group == "DEAD_SELLER":
            action = "FLAG_MANUAL_SUPPORT"

        elif group == "LOW_TRAFFIC":
            action = "BOOST_VISIBILITY"

        elif group == "LOW_CONVERSION":
            # Only create if rating qualifies
            if rating >= MIN_RATING:
                voucher_type = "DEEP_DISCOUNT"
                discount     = round(random.uniform(DEEP_DISCOUNT_MIN,
                                                    DEEP_DISCOUNT_MAX), 2)
                if check_existing_voucher(db, seller_id, voucher_type):
                    log.info("  🚫  Duplicate voucher detected — skipping (%s / %s)",
                             seller_id, voucher_type)
                    duplicates_prevented += 1
                    action = "DUPLICATE_SKIPPED"
                else:
                    create_voucher(db, seller_id, metrics["sellerName"], voucher_type, discount)
                    vouchers_created += 1
                    action = "CREATE_VOUCHER"
            else:
                log.info("  ⛔  Rating %.1f < %.1f — voucher not eligible.", rating, MIN_RATING)
                action = "INELIGIBLE_RATING"

        elif group == "LOW_REVENUE":
            if rating >= MIN_RATING:
                voucher_type = "UPSELL"
                discount     = UPSELL_DISCOUNT
                if check_existing_voucher(db, seller_id, voucher_type):
                    log.info("  🚫  Duplicate voucher detected — skipping (%s / %s)",
                             seller_id, voucher_type)
                    duplicates_prevented += 1
                    action = "DUPLICATE_SKIPPED"
                else:
                    create_voucher(db, seller_id, metrics["sellerName"], voucher_type,
                                   discount, UPSELL_MIN_ORDER_VALUE)
                    vouchers_created += 1
                    action = "CREATE_VOUCHER"
            else:
                log.info("  ⛔  Rating %.1f < %.1f — voucher not eligible.", rating, MIN_RATING)
                action = "INELIGIBLE_RATING"

        # ── Update tier in Firestore ──────────────────────────────────
        update_seller_tier(db, seller_id, group)

        # ── Append detail row ─────────────────────────────────────────
        detail_row: dict = {
            "sellerId"  : seller_id,
            "group"     : group,
            "action"    : action,
            "metrics"   : {
                "totalViews"     : metrics["totalViews"],
                "totalOrders"    : metrics["totalOrders"],
                "revenue"        : metrics["revenue"],
                "conversionRate" : round(metrics["conversionRate"], 4),
                "AOV"            : round(metrics["AOV"], 0),
                "rating"         : rating,
            },
        }
        if discount is not None:
            detail_row["discount"]     = discount
        if voucher_type is not None:
            detail_row["voucherType"]  = voucher_type

        details.append(detail_row)

    # ── Build final report ────────────────────────────────────────────────
    report = {
        "summary"                   : summary,
        "vouchersCreated"           : vouchers_created,
        "duplicatesPrevented"       : duplicates_prevented,
        "expectedRevenueBoostPercent": "10-25%",
        "details"                   : details,
        "generatedAt"               : datetime.now(timezone.utc).isoformat(),
    }

    return report


# ─────────────────────────────── entrypoint ─────────────────────────────────

if __name__ == "__main__":
    log.info("╔══════════════════════════════════════════════════════════╗")
    log.info("║          AI VOUCHER PIPELINE  —  DakLak Agri            ║")
    log.info("╚══════════════════════════════════════════════════════════╝")

    report = run_pipeline()

    # Pretty-print JSON report
    print("\n" + "=" * 70)
    print("[PIPELINE REPORT]")
    print("=" * 70)
    print(json.dumps(report, indent=2, ensure_ascii=True, default=str))

    # Persist report to file
    report_filename = (
        f"pipeline_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    )
    with open(report_filename, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False, default=str)

    log.info("Report saved → %s", report_filename)
    log.info("Pipeline complete. ✓")
