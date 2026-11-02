// UI được làm mới cho bộ 18 Tasks; giữ nguyên luồng state/service của source Chương 5.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../chapter5_ui.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/reminder_repository.dart';
import '../controllers/daily_reminder_controller.dart';
import '../widgets/reminder_widgets.dart';
import '../../services/reminder_notification_service.dart';


class DailyReminderPage
    extends StatefulWidget {
  const DailyReminderPage({
    super.key,
    required this.repository,
    this.openedFromNotification = false,
  });

  final ReminderRepository repository;
  final bool openedFromNotification;

  @override
  State<DailyReminderPage> createState() => _DailyReminderPageState();
}

class _DailyReminderPageState
    extends State<DailyReminderPage> {
  late final DailyReminderController controller;

  static const dayNames = {
    1: 'T2',
    2: 'T3',
    3: 'T4',
    4: 'T5',
    5: 'T6',

    6: 'T7',
    7: 'CN',
  };

  @override
  void initState() {
    super.initState();

    controller =
        DailyReminderController(
      repository: widget.repository,
      notifications:
          ReminderNotificationService.instance,
    );

    controller.initialize();
  }

  @override
  // giải phóng khi rời trang
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // h.thị lỗi bằng snackbar
  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  // mở timpicker rồi lưu giờ đã chọn qua controller
  Future<void> _pickTime() async {
    final selected =
        await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(
        hour:controller.settings.hour,
        minute:
            controller.settings.minute,
      ),
      helpText:
          'Chọn giờ nhắc học',
      cancelText: 'Hủy',
      confirmText: 'Lưu',
    );

    if (selected == null) return;

    await controller.setTime(selected);

    if (!mounted) return;

    _snack(
      controller.settings.enabled
          ? 'Đã cập nhật và lập lại lịch ''${controller.settings.timeLabel}.'
          : 'Đã lưu giờ '
              '${controller.settings.timeLabel}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor:
              reminderBackground,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Về trang chủ 18 Tasks',
              icon: const Icon(Icons.home_rounded),
              onPressed: () => context.go('/'),
            ),
            backgroundColor:
                reminderBackground,
            surfaceTintColor:
                Colors.transparent,
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      reminderGreen,
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10),
                Text('Daily Reminder',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: _body(),
        );
      },
    );
  }


  Widget _body() {
    if (controller.status ==DailyReminderStatus.loading) {
      return const Center(
        child:CircularProgressIndicator(
          color: reminderGreen,
        ),
      );
    }

    if (controller.status ==
        DailyReminderStatus.error) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 58,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage ??
                    'Không thể tải cấu hình.',
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed:
                    controller.initialize,
                child:
                    const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32,
        ),
        children: [
          _chapterOverview(),
          const SizedBox(height: 17),
          if (widget.openedFromNotification) ...[
            _openedFromNotificationCard(),
            const SizedBox(height: 14),
          ],

          // luôn cho phép bật/tắt nhanh khi chưa k.hoạt lịch
          _activeCard(),
          const SizedBox(height: 14),


          _upcomingCard(),

          const SizedBox(height: 14),

          _timeCard(),

          const SizedBox(height: 14),

          _daysCard(),

          const SizedBox(height: 14),

          _permissionCard(),

          const SizedBox(height: 14),


          _suggestionCard(),

          const SizedBox(height: 18),

          _actions(),
        ],
      ),
    );
  }


  // trang giới thiệu bài 
  Widget _chapterOverview() {
    final settings = controller.settings;
    return Chapter5Hero(
      eyebrow: 'Task 13  •  Local notification',
      title: 'Thiết kế nhịp học của bạn.',
      description: 'Chọn thời điểm phù hợp. Xem trước lịch học trong tuần, sau đó bật thông báo để bắt đầu.',
      icon: Icons.notifications_active_outlined,
      from: const Color(0xFF153F39),
      to: const Color(0xFF2C9373),
      status: settings.enabled ? 'Đang bật nhắc học' : 'Chưa bật nhắc học',
      detail: '${settings.timeLabel}  •  ${settings.repeatDays.length} ngày/tuần',
    );
  }

  // t.báo app được khởi chạy = cách chạm notification
  Widget _openedFromNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            reminderDarkGreen,
            reminderGreen,
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor:
                Color(0x33FFFFFF),
            child: Icon(
              Icons
                  .notifications_active_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Mở từ thông báo nhắc học',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Chào mừng quay lại. '
                  'Tiếp tục mục tiêu Flutter '
                  'hôm nay nhé 🚀',
                  style: TextStyle(
                    color:
                        Color(0xFFE9FFEE),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // trạng thái lịch 
  Widget _activeCard() {
    final enabled = controller.settings.enabled;
    final next = controller.nextReminder;
    final nextText = next == null
        ? 'Chưa có thông báo nào được lên lịch'
        : DateFormat('EEEE, dd/MM • HH:mm', 'vi_VN').format(next);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: enabled ? reminderDarkGreen : const Color(0xFFE7F1EB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: enabled ? const Color(0x334EE4B0) : Colors.white,
            child: Icon(
              enabled ? Icons.notifications_active_rounded : Icons.notifications_paused_outlined,
              color: enabled ? Colors.white : reminderGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? 'Lịch nhắc đang hoạt động' : 'Chưa bật nhắc học',
                  style: TextStyle(
                    color: enabled ? Colors.white : reminderDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  enabled ? 'Lần nhắc tiếp: $nextText' : 'Chỉnh giờ và ngày bên dưới rồi kích hoạt.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: enabled ? const Color(0xFFD6F5E6) : reminderDarkGreen,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeTrackColor: const Color(0xFF8FE8C8),
            onChanged: (value) async {
              final ok = await controller.toggleEnabled(value);
              if (!mounted) return;
              if (!ok) _snack('Hãy cấp quyền thông báo trước khi bật lịch.');
            },
          ),
        ],
      ),
    );
  }


  List<DateTime> _nextThreeDates() {
    final settings = controller.settings;
    final now = DateTime.now();
    final dates = <DateTime>[];
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = 0; offset < 21 && dates.length < 3; offset++) {
      final day = today.add(Duration(days: offset));
      if (!settings.repeatDays.contains(day.weekday)) continue;
      final candidate = DateTime(
        day.year, day.month, day.day, settings.hour, settings.minute,
      );
      if (candidate.isAfter(now)) dates.add(candidate);
    }
    return dates;
  }


  Widget _upcomingCard() {
    final dates = _nextThreeDates();
    final isEnabled = controller.settings.enabled;
    return ReminderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available_rounded, color: reminderGreen),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '3 lần nhắc sắp tới',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isEnabled
                ? 'Các mốc dự kiến theo lịch bạn đã bật.'
                : 'Xem trước theo giờ và ngày đã chọn; chưa gửi thông báo.',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (dates.isEmpty)
            const Text('Hãy chọn ít nhất một ngày nhắc học.')
          else
            Row(
              children: [
                for (var i = 0; i < dates.length; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
                      decoration: BoxDecoration(
                        color: i == 0 ? reminderSoftGreen : const Color(0xFFF3F5F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE', 'vi_VN').format(dates[i]),
                            style: const TextStyle(fontSize: 11, color: reminderDarkGreen),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('dd/MM').format(dates[i]),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('HH:mm').format(dates[i]),
                            style: const TextStyle(fontSize: 12, color: reminderGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // phần chọn giờ nhắc, hỗ trợ timepicker và điều chỉnh giờ/phút tr.tiếp
  Widget _timeCard() {
    return ReminderCard(
      child: Column(
        children: [
          const Text(
            'Thời điểm nhắc học',
            style: TextStyle(
              color: Colors.black54,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: _pickTime,
            borderRadius:
                BorderRadius.circular(16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color:
                    reminderSoftGreen,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Text(
                controller
                    .settings.timeLabel,
                style: const TextStyle(
                  color: reminderGreen,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 40,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  controller
                      .adjustMinutes(-15);
                },
                icon: const Icon(
                  Icons.remove,
                ),
              ),

              const SizedBox(width: 12),

              const Row(
                children: [
                  Icon(
                    Icons.bedtime_outlined,
                    size: 17,
                    color:
                        reminderGreen,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Điều chỉnh 15 phút',
                    style: TextStyle(
                      color:
                          Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              IconButton.filledTonal(
                onPressed: () {
                  controller
                      .adjustMinutes(15);
                },
                icon:
                    const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // chọn các ngày lặp trong tuần
  Widget _daysCard() {
    return ReminderCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .calendar_month_rounded,
                color: reminderGreen,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lặp lại theo ngày',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children:
                List.generate(7,
              (index) {
                final day =
                    index + 1;

                final selected =
                    controller
                        .settings
                        .repeatDays
                        .contains(day);

                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 2,
                    ),
                    child:
                        GestureDetector(
                      onTap: () async {
                        final ok =await controller.toggleDay(day,);

                        if (!mounted) {
                          return;
                        }

                        if (!ok) {
                          _snack(
                            'Phải chọn ít nhất '
                            '1 ngày.',
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 180,
                        ),
                        height: 42,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? reminderGreen
                              : const Color(
                                  0xFFF0F3F5,
                                ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child: Text(
                          dayNames[day]!,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors
                                    .black54,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label:
                    const Text(
                  'Thứ 2 - Thứ 6',
                ),
                onPressed: () {
                  controller
                      .selectWeekdays();
                },
              ),
              ActionChip(
                label:
                    const Text(
                  'Cả tuần',
                ),
                onPressed: () {
                  controller
                      .selectEveryDay();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // hiển thị quyền notification
  Widget _permissionCard() {
    final notificationOk =
        controller
            .permission
            .notificationsGranted;

    final exactOk =
        controller
            .permission
            .exactAlarmGranted;

    return ReminderCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                notificationOk
                    ? reminderSoftGreen
                    : const Color(
                        0xFFFFECEB,
                      ),
            child: Icon(
              notificationOk
                  ? Icons
                      .verified_rounded
                  : Icons
                      .notifications_off_outlined,
              color: notificationOk
                  ? reminderGreen
                  : Colors.redAccent,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quyền thông báo',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notificationOk
                      ? exactOk
                          ? 'Đã sẵn sàng gửi '
                              'thông báo đúng giờ'
                          : 'Đã cho phép thông báo • '
                              'lịch chính xác chưa được cấp'
                      : 'Chưa cấp quyền '
                          'thông báo',
                  style: TextStyle(
                    fontSize: 12,
                    color: notificationOk
                        ? reminderGreen
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          if (!notificationOk ||  !exactOk)
            TextButton(
              onPressed: () async {
                await controller
                    .requestPermissions();

                if (!mounted) return;

                _snack(
                  controller
                          .permission
                          .notificationsGranted
                      ? 'Đã cập nhật quyền.'
                      : 'Quyền thông báo '
                          'chưa được cấp.',
                );
              },
              child:
                  const Text('Cấp quyền'),
            ),
        ],
      ),
    );
  }

  // gợi ý học từ api 
  Widget _suggestionCard() {
    return ReminderCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor:
                    Color(0xFFE8EDF3),
                child: Icon(
                  Icons
                      .auto_stories_outlined,
                  size: 19,
                  color: reminderGreen,
                ),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ví dụ công việc từ API',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      'JSONPlaceholder • dữ liệu mẫu, không phải bài học thật',
                      style: TextStyle(
                        color:
                            Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed:
                    controller
                            .suggestionLoading
                        ? null
                        : controller
                            .refreshSuggestion,
                icon:
                    const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (controller
              .suggestionLoading)
            const LinearProgressIndicator(
              color: reminderGreen,
            )
          else if (controller
                  .suggestionError !=
              null)
            Container(
              padding:
                  const EdgeInsets.all(12),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFFECEB,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .cloud_off_outlined,
                    color:
                        Colors.redAccent,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      controller
                          .suggestionError!,
                      style:
                          const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        controller
                            .refreshSuggestion,
                    child:
                        const Text(
                      'Thử lại',
                    ),
                  ),
                ],
              ),
            )
          else if (controller
                  .suggestion !=
              null)
            Container(
              padding:
                  const EdgeInsets.all(13),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF1F4F6,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    controller
                        .suggestion!.title,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        'ID #${controller.suggestion!.id}',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        controller
                                .suggestion!
                                .completed
                            ? 'Đã hoàn thành'
                            : 'Chưa hoàn thành',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                          color: controller
                                  .suggestion!
                                  .completed
                              ? reminderGreen
                              : Colors
                                  .orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // các nút test notification
  Widget _actions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style:
                FilledButton.styleFrom(
              backgroundColor:
                  reminderGreen,
            ),
            onPressed: () async {
              final ok =
                  await controller
                      .enableReminder();

              if (!mounted) return;

              _snack(
                ok
                    ? 'Đã lập lịch '
                        '${controller.settings.timeLabel} '
                        '• ${controller.settings.repeatLabel}.'
                    : 'Không thể bật lịch. '
                        'Hãy cấp quyền thông báo.',
              );
            },
            icon: const Icon(
              Icons
                  .notification_add_rounded,
            ),
            label: Text(
              controller.settings.enabled
                  ? 'Cập nhật lịch nhắc'
                  : 'Lập lịch nhắc nhở',
            ),
          ),
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            Expanded(
              child:
                  OutlinedButton.icon(
                onPressed: () async {
                  final ok =
                      await controller
                          .testNow();

                  if (!mounted) return;

                  _snack(
                    ok
                        ? 'Đã gửi thông báo '
                            'test ngay.'
                        : 'Chưa có quyền '
                            'thông báo.',
                  );
                },
                icon: const Icon(
                  Icons
                      .send_to_mobile_outlined,
                ),
                label:
                    const Text('Test ngay'),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child:
                  OutlinedButton.icon(
                onPressed: () async {
                  final ok =
                      await controller
                          .testAfter10Seconds();

                  if (!mounted) return;

                  _snack(
                    ok
                        ? 'Đã đặt thông báo '
                            'test sau 10 giây.'
                        : 'Chưa có quyền '
                            'thông báo.',
                  );
                },
                icon: const Icon(
                  Icons.timer_outlined,
                ),
                label:
                    const Text('Test 10 giây'),
              ),
            ),
          ],
        ),

        if (controller.settings.enabled) ...[
          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton.icon(
              style:
                  TextButton.styleFrom(
                foregroundColor:
                    Colors.redAccent,
              ),
              onPressed: () async {
                final confirm =
                    await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Hủy lịch nhắc?',
                      ),
                      content: const Text(
                        'Các thông báo đã lập lịch '
                        'của Bài 13 sẽ bị hủy.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              false,
                            );
                          },
                          child:
                              const Text(
                            'Không',
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              true,
                            );
                          },
                          child:
                              const Text(
                            'Hủy lịch',
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirm != true) {
                  return;
                }

                await controller
                    .disableReminder();

                if (!mounted) return;

                _snack(
                  'Đã hủy lịch nhắc.',
                );
              },
              icon: const Icon(
                Icons
                    .event_busy_outlined,
              ),
              label:
                  const Text('Hủy lịch nhắc'),
            ),
          ),
        ],

        const SizedBox(height: 12),

        const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done_outlined,
              size: 15,
              color: Colors.black45,
            ),
            SizedBox(width: 5),
            Text(
              'Giờ, ngày lặp và trạng thái '
              'được lưu tự động',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}