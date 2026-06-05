"""
╔══════════════════════════════════════════════════════════════════════════════╗
║          CLEANUP SCRIPT — Stale Orders (sellerId = "unknown")              ║
║          Project : daklakagent (Firebase)                                  ║
║          Purpose : Find & delete orders written before the checkout fix    ║
║                    that have sellerId == "unknown".                         ║
║                                                                            ║
║  USAGE                                                                     ║
║    # Dry-run first (safe — no writes):                                     ║
║        python cleanup_stale_orders.py                                      ║
║                                                                            ║
║    # Actually delete:                                                      ║
║        python cleanup_stale_orders.py --delete                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import argparse
import logging
import sys
from datetime import datetime, timezone

import firebase_admin
from firebase_admin import credentials, firestore

# ─────────────────────────── config ─────────────────────────────────────────
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"

# ─────────────────────────── logging ────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("cleanup_stale_orders")


# ─────────────────────── Firebase initialisation ────────────────────────────
def init_firebase() -> firestore.client:
    """Initialise Firebase Admin SDK and return a Firestore client."""
    # Guard: don't re-initialise if already done
    if not firebase_admin._apps:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    log.info("Firebase initialised  (project: daklakagent)")
    return db


# ─────────────────────── Cleanup logic ──────────────────────────────────────
def cleanup_stale_orders(db: firestore.client, dry_run: bool = True) -> None:
    """
    Find all orders where sellerId == "unknown" and:
      - DRY-RUN mode : just log them (safe, no writes).
      - DELETE mode  : permanently delete them from Firestore.

    Args:
        db      : Firestore client.
        dry_run : If True, only log — do NOT write to Firestore.
    """
    mode_label = "DRY-RUN" if dry_run else "DELETE"
    log.info("=" * 70)
    log.info("Mode: %s — querying orders where sellerId == 'unknown' …", mode_label)
    log.info("=" * 70)

    query = (
        db.collection("orders")
          .where(filter=firestore.FieldFilter("sellerId", "==", "unknown"))
    )
    stale_docs = list(query.stream())

    if not stale_docs:
        log.info("✅  No stale orders found. Nothing to do.")
        return

    log.info("Found %d stale order(s):", len(stale_docs))
    for doc in stale_docs:
        data = doc.to_dict()
        created = data.get("createdAt", "N/A")
        total   = data.get("totalAmount", 0)
        log.info(
            "  📄  id=%-28s | createdAt=%s | totalAmount=%.0f",
            doc.id, created, total,
        )

    if dry_run:
        log.info("")
        log.info("DRY-RUN complete. No documents were modified.")
        log.info("To actually delete them, run:  python cleanup_stale_orders.py --delete")
        return

    # ── Perform deletion ─────────────────────────────────────────────────────
    log.info("")
    log.info("Deleting %d stale order(s) …", len(stale_docs))

    batch     = db.batch()
    BATCH_MAX = 500          # Firestore batch limit

    for i, doc in enumerate(stale_docs):
        batch.delete(doc.reference)
        # Commit every BATCH_MAX ops to stay within Firestore limits
        if (i + 1) % BATCH_MAX == 0:
            batch.commit()
            log.info("  Committed batch of %d deletions.", BATCH_MAX)
            batch = db.batch()

    # Commit any remaining deletes
    batch.commit()

    log.info("✅  Deleted %d stale order(s) from Firestore.", len(stale_docs))
    log.info("    Timestamp: %s", datetime.now(timezone.utc).isoformat())


# ─────────────────────────── entrypoint ─────────────────────────────────────
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Cleanup stale Firestore orders with sellerId == 'unknown'."
    )
    parser.add_argument(
        "--delete",
        action="store_true",
        default=False,
        help="Actually DELETE the stale orders. Without this flag, the script runs in dry-run mode.",
    )
    args = parser.parse_args()

    dry_run = not args.delete

    log.info("╔══════════════════════════════════════════════════════════╗")
    log.info("║   STALE ORDER CLEANUP  —  DakLak Agri                   ║")
    log.info("╚══════════════════════════════════════════════════════════╝")

    db = init_firebase()
    cleanup_stale_orders(db, dry_run=dry_run)

    log.info("Done.")


if __name__ == "__main__":
    main()
