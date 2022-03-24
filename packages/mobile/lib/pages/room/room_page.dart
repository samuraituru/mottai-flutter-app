import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ks_flutter_commons/ks_flutter_commons.dart';
import 'package:mottai_flutter_app/controllers/room/room_page_controller.dart';
import 'package:mottai_flutter_app/providers/message/message_provider.dart';
import 'package:mottai_flutter_app/route/utils.dart';
import 'package:mottai_flutter_app/theme/theme.dart';
import 'package:mottai_flutter_app/utils/utils.dart';
import 'package:mottai_flutter_app_models/models.dart';

const double horizontalPadding = 8;
const double partnerImageSize = 36;

class RoomPage extends StatefulHookConsumerWidget {
  const RoomPage({Key? key}) : super(key: key);

  static const path = '/room/';
  static const name = 'RoomPage';

  @override
  ConsumerState<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage> {
  @override
  Widget build(BuildContext context) {
    final roomId =
        (ModalRoute.of(context)!.settings.arguments! as RouteArguments)['roomId'] as String;
    return TapToUnfocusWidget(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ref.watch(messagesStreamProvider(roomId)).when(
                    loading: () => const SizedBox(),
                    error: (error, stackTrace) {
                      print('=============================');
                      print('⛔️ $error');
                      print(stackTrace);
                      print('=============================');
                      return const SizedBox();
                    },
                    data: (messages) => Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          if (message.senderId == nonNullUid) {
                            return _buildMessageByMyself(message);
                          } else {
                            return _buildMessageByPartner(message);
                          }
                        },
                        itemCount: messages.length,
                        reverse: true,
                      ),
                    ),
                  ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: messageBackgroundColor,
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller:
                          ref.watch(roomPageController(roomId).notifier).textEditingController,
                      minLines: 1,
                      maxLines: 5,
                      style: regular14,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 16,
                          right: 36,
                          top: 8,
                          bottom: 8,
                        ),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'メッセージを入力',
                        hintStyle: regular12,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            await ref.read(roomPageController(roomId).notifier).send();
                          },
                          child: const Icon(
                            Icons.send,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 相手からのメッセージ
  Widget _buildMessageByPartner(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CircleImage(
                  size: 36,
                  imageURL:
                      'https://firebasestorage.googleapis.com/v0/b/mottai-app-dev-2.appspot.com/o/hosts%2Fyago-san.jpeg?alt=media&token=637a9f78-9243-4ce8-8734-5776a40cc7fd'),
              const Gap(8),
              Container(
                constraints: BoxConstraints(
                  maxWidth: (MediaQuery.of(context).size.width -
                          partnerImageSize -
                          horizontalPadding * 3) *
                      0.9,
                ),
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: messageBackgroundColor,
                ),
                child: Text(message.body, style: regular12),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              left: partnerImageSize + horizontalPadding,
              bottom: 16,
            ),
            child: Text(timeString(message.createdAt), style: grey12),
          ),
        ],
      ),
    );
  }

  /// 自分からのメッセージ
  Widget _buildMessageByMyself(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  (MediaQuery.of(context).size.width - partnerImageSize - horizontalPadding * 3) *
                      0.9,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(message.body, style: white12),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(timeString(message.createdAt), style: grey12),
          ),
        ],
      ),
    );
  }
}
