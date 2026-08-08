import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommunityPostsScreen extends StatefulWidget {
  const CommunityPostsScreen({super.key});

  @override
  State<CommunityPostsScreen> createState() => _CommunityPostsScreenState();
}

class _CommunityPostsScreenState extends State<CommunityPostsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa bài viết này khỏi hệ thống không?\nHành động này không thể hoàn tác.',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Xóa Bài Viết', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('posts').doc(postId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Đã xóa bài viết thành công'),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa bài viết: $e'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _approvePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({'status': 'approved'});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt bài viết')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _togglePin(String postId, bool currentPinStatus) async {
    try {
      await _firestore.collection('posts').doc(postId).update({'isPinned': !currentPinStatus});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(!currentPinStatus ? 'Đã ghim bài viết' : 'Đã bỏ ghim bài viết')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showCreatePostDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng bài mới', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Nội dung bài viết...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              try {
                await _firestore.collection('posts').add({
                  'content': textController.text.trim(),
                  'userId': 'admin',
                  'userName': 'Quản trị viên',
                  'userRole': 'admin',
                  'status': 'approved',
                  'timestamp': FieldValue.serverTimestamp(),
                  'likes': [],
                  'hashtags': [],
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng bài thành công')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            },
            child: const Text('Đăng Bài'),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => _CommentsDialog(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.forum_rounded, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiểm duyệt Cộng đồng',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý và kiểm duyệt các bài viết từ người dùng trên hệ thống',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showCreatePostDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Đăng bài', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // List of Posts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  );
                }

                final posts = snapshot.data?.docs ?? [];
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.speaker_notes_off_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có bài viết nào',
                          style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800), // Ràng buộc chiều rộng tối đa
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: posts.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final data = post.data() as Map<String, dynamic>;
                        
                        final timestamp = data['timestamp'] as Timestamp?;
                        final dateStr = timestamp != null 
                            ? DateFormat('HH:mm - dd/MM/yyyy').format(timestamp.toDate()) 
                            : 'Thời gian không xác định';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Author Info & Actions
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey[200]!, width: 2),
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.grey[100],
                                        backgroundImage: data['userPhotoUrl'] != null && data['userPhotoUrl'].toString().isNotEmpty
                                            ? NetworkImage(data['userPhotoUrl'])
                                            : null,
                                        child: data['userPhotoUrl'] == null || data['userPhotoUrl'].toString().isEmpty
                                            ? Icon(Icons.person, color: Colors.grey[400])
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['userName'] ?? 'Người dùng ẩn danh',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
                                              const SizedBox(width: 4),
                                              Text(
                                                dateStr,
                                                style: TextStyle(
                                                  color: Colors.grey[500], 
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    if (data['status'] == 'pending') ...[
                                      ElevatedButton.icon(
                                        onPressed: () => _approvePost(post.id),
                                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                                        label: const Text('Duyệt'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (data['status'] == 'approved') ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('Đã duyệt', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Tooltip(
                                      message: (data['isPinned'] ?? false) ? 'Bỏ ghim' : 'Ghim bài',
                                      child: IconButton(
                                        icon: Icon((data['isPinned'] ?? false) ? Icons.push_pin : Icons.push_pin_outlined),
                                        color: (data['isPinned'] ?? false) ? Colors.red : Colors.grey,
                                        onPressed: () => _togglePin(post.id, data['isPinned'] ?? false),
                                      ),
                                    ),
                                    // Delete Button
                                    Material(
                                      color: Colors.transparent,
                                      child: Tooltip(
                                        message: 'Xóa bài viết này',
                                        child: InkWell(
                                          onTap: () => _deletePost(post.id),
                                          borderRadius: BorderRadius.circular(12),
                                          hoverColor: Colors.red.withOpacity(0.1),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.red.withOpacity(0.1)),
                                            ),
                                            child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Post Content
                                Text(
                                  data['content'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                                
                                // Image Attachment
                                if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      constraints: const BoxConstraints(maxHeight: 400),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        border: Border.all(color: Colors.grey[100]!),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Image.network(
                                        data['imageUrl'],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => 
                                            const Padding(
                                              padding: EdgeInsets.all(32.0),
                                              child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                                
                                // Hashtags
                                if (data['hashtags'] != null && (data['hashtags'] as List).isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (data['hashtags'] as List).map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Divider(),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _showCommentsDialog(post.id),
                                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: Colors.grey),
                                      label: const Text('Xem & Bình luận', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsDialog extends StatefulWidget {
  final String postId;
  const _CommentsDialog({required this.postId});

  @override
  State<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<_CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _replyTo(String userName) {
    _commentController.text = '@$userName ';
    _focusNode.requestFocus();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await _firestore.collection('posts').doc(widget.postId).collection('comments').add({
      'text': _commentController.text.trim(),
      'userId': 'admin',
      'userName': 'Quản trị viên',
      'userRole': 'admin',
      'userPhotoUrl': '',
      'parentCommentId': null,
      'likes': [],
      'reactions': {},
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bình luận bài viết', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 600,
        height: 450,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final comments = snapshot.data?.docs ?? [];
                  if (comments.isEmpty) return const Center(child: Text('Chưa có bình luận nào'));
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index].data() as Map<String, dynamic>;
                      final userName = comment['userName'] ?? 'User';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                const Spacer(),
                                InkWell(
                                  onTap: () => _replyTo(userName),
                                  child: const Text('Trả lời', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(comment['text'] ?? comment['content'] ?? '', style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Viết bình luận dưới tên Quản trị viên...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _submitComment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng', style: TextStyle(color: Colors.grey))),
      ],
    );
  }
}
