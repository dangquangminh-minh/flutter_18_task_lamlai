import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../chapter4_back_scope.dart';
import '../../services/campaign_coordinator.dart';

import '../controllers/campaign_hub_controller.dart';


class CampaignHubPage extends StatefulWidget {
  const CampaignHubPage({super.key});

  @override
  State<CampaignHubPage> createState() => _CampaignHubPageState();
}

class _CampaignHubPageState extends State<CampaignHubPage> {

  static const dark = Color(0xFF151E23);
  static const lime = Color(0xFFCBF268);
  static const paper = Color(0xFFF2F5EF);

  late final CampaignHubController controller;
  late final TextEditingController input;

  bool busy = false;


  static const samples = [
    (12, 'qr', 'Summer Launch', Icons.qr_code_rounded),
    (45, 'banner', 'Creative Week', Icons.web_rounded),

    (88, 'email', 'Newsletter Drop', Icons.mail_outline_rounded),
    (99, 'qr', 'Member Preview', Icons.local_activity_outlined),
  ];

  @override
  void initState() {
    super.initState();


    controller = CampaignHubController(
      coordinator: CampaignCoordinator.instance,
    );

    // giữ nd link b.đầu
    input = TextEditingController(text: controller.rawLink);
  }

  @override
  void dispose() {
    // giải phóng controller khi rời khỏi m.hình
    input.dispose();
    controller.dispose();
    super.dispose();
  }

  // hiển thị thông báo ngắn cho ng.dùng
  void _snack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

// sửa lỗi k quay về đc homepage
  void _goHome() {
    context.go('/');
  }

  // mở campaign theo link đang nhập
  Future<void> _open() async {
    if (busy) return;

    final rawLink = input.text.trim();

    if (rawLink.isEmpty) {
      _snack('Bạn chưa nhập liên kết chiến dịch.');
      return;
    }

    setState(() {
      busy = true;
    });

    controller.updateRawLink(rawLink);

    try {
     
      final route = await controller.dispatch();

      if (!mounted) return;


      context.push(route);
    } catch (error) {
      _snack('Không xử lý được liên kết: $error');
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // sao chép lk vào clipboard
  Future<void> _copy() async {
    final link = input.text.trim();

    if (link.isEmpty) {
      _snack('Chưa có liên kết để sao chép.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: link));

    _snack('Đã sao chép liên kết.');
  }

  // chọn campaign mẫu và đưa link tương ứng vào ô nhập
  void _select(int id, String source) {
    controller.selectCampaign(id: id, source: source);

    setState(() {
      input.text = controller.rawLink;
    });
  }

 
  void _sign() {
    controller.updateRawLink(input.text.trim());

    final signed = controller.createSignedLink();

    if (signed == null) {
      _snack(
        'Link chưa hợp lệ hoặc thiếu '
        'CAMPAIGN_DEMO_HMAC_KEY (tối thiểu 16 ký tự).',
      );
      return;
    }

    setState(() {
      input.text = signed;
    });

    _snack('Đã tạo signed link có thời hạn.');
  }


  Future<void> _share() async {
    final link = input.text.trim();

    if (link.isEmpty) {
      _snack('Chưa có liên kết để chia sẻ.');
      return;
    }

    await SharePlus.instance.share(ShareParams(text: link));
  }

  // Đăng xuất tài khoản demo, không xóa dữ liệu campaign đã cache.
  Future<void> _logout() async {
    await controller.logout();

    if (!mounted) return;

    _snack('Đã đăng xuất tài khoản demo.');
  }


  Widget _campaignCard((int, String, String, IconData) item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _select(item.$1, item.$2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E9E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F5C9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(item.$4, color: dark),
              ),

              const Spacer(),

              Text(
                item.$3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'CAMPAIGN ${item.$1} / ${item.$2.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF738071),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.north_east_rounded, color: Color(0xFF4B7065)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // banner chính: h.thị trạng thái đăng nhập
  
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: lime),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'CAMPAIGN GATEWAY / TASK 12',
                  style: TextStyle(
                    color: lime,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
              ),


              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: controller.signedIn ? lime : const Color(0xFFFFBF7D),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          const Text(
            'Liên kết thông minh.\nĐúng hành trình.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 27,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            controller.signedIn
                ? 'Đã đăng nhập demo. Bạn có thể mở '
                      'trực tiếp các chiến dịch.'
                : 'Chưa đăng nhập. Hệ thống sẽ giữ liên kết '
                      'và chuyển đến trang đăng nhập.',
            style: const TextStyle(
              color: Color(0xFFBFCCC7),
              height: 1.5,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: input,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _open(),
            decoration: InputDecoration(
              hintText: 'myapp://campaign/12?source=qr',
              prefixIcon: const Icon(
                Icons.link_rounded,
                color: Color(0xFF476B5E),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: busy ? null : _open,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(busy ? 'Đang xử lý...' : 'Mở liên kết chiến dịch'),
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: dark,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF5A6969)),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sign,
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Ký link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF5A6969)),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF5A6969)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCampaignList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bộ sưu tập chiến dịch',
          style: TextStyle(
            color: dark,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Chạm vào một chiến dịch để điền link, '
          'sau đó mở hoặc chia sẻ.',
          style: TextStyle(color: Color(0xFF6B786F), fontSize: 12),
        ),

        const SizedBox(height: 14),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: samples.map(_campaignCard).toList(),
        ),
      ],
    );
  }

  // Thông báo rõ đây là bài thực hành đăng nhập và ký link.
  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECCF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: dark),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Đăng nhập chỉ là demo lưu bằng Hive. '
              'Ký link trong ứng dụng phục vụ bài thực hành, '
              'không phải cơ chế bảo mật production.',
              style: TextStyle(fontSize: 12, height: 1.45, color: dark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Nếu Hub được mở trực tiếp từ Deep Link,
        // bấm Back Android sẽ về Homepage thay vì thoát app.
        return Chapter4BackScope(
          fallbackPath: '/',
          child: Scaffold(
            backgroundColor: paper,

            appBar: AppBar(
              backgroundColor: paper,
              foregroundColor: dark,
              surfaceTintColor: Colors.transparent,

              // nut hone trỏ về homepage
              leading: IconButton(
                tooltip: 'Về trang chủ',
                icon: const Icon(Icons.home_rounded),
                onPressed: _goHome,
              ),

              title: const Text(
                'Gateway Lab',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),

              actions: [

                IconButton(
                  tooltip: 'Quét QR',
                  onPressed: () {
                    context.push('/campaign-scanner');
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                ),

                PopupMenuButton<String>(
                  tooltip: 'Tài khoản demo',
                  onSelected: (value) async {
                    if (value == 'login') {
                      context.push('/campaign-login');
                    } else if (value == 'logout') {
                      await _logout();
                    } else if (value == 'home') {
                      _goHome();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'login',
                      child: Text(
                        controller.signedIn
                            ? 'Xem đăng nhập demo'
                            : 'Đăng nhập demo',
                      ),
                    ),

                    if (controller.signedIn)
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Đăng xuất'),
                      ),

                    const PopupMenuDivider(),

                    const PopupMenuItem(
                      value: 'home',
                      child: Text('Về trang chủ 18 Task'),
                    ),
                  ],
                ),
              ],
            ),

            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(17, 8, 17, 30),
                children: [
                  _buildHero(),

                  const SizedBox(height: 24),

                  _buildCampaignList(),

                  const SizedBox(height: 19),

                  _buildNotice(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
