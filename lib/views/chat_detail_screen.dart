import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "안녕하세요. 무엇을 도와드릴까요?",
      "isMine": false,
      "timestamp": DateTime.now(),
    },
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> autoReplies = {
    "안녕": "안녕하세요. 무엇을 도와드릴까요?",
    "시간": "네, 복약 시간은 효과에 큰 영향을 미칠 수 있습니다.",
    "항생제": "병이 나은거 같다고 하더라도, 항생제는 내성이 생길 수 있으니 끝까지 모두 복용하셔야 합니다.",
    "오메가": "오메가3는 기름기 있는 음식과 함께 복용하면 흡수율이 높아져요.",
    "식전": "식전에 복용하는 약은 보통 공복 상태에서 더 잘 흡수되는 약입니다.",
    "식후": "식후 복용은 위장 자극을 줄이거나 흡수를 돕기 위해 권장됩니다.",
    "감기약": "감기약은 졸릴 수 있으니 운전 전엔 복용을 피하세요.",
    "두통약": "카페인 성분이 포함된 경우가 있으니 커피와 함께 복용은 피해주세요.",
  };

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    setState(() {
      _messages.add({"text": text, "isMine": true, "timestamp": now});
      _textController.clear();
    });

    _scrollToBottom(); // ⬅️ 내가 보낸 메시지 후 스크롤

    bool matched = false;
    for (final keyword in autoReplies.keys) {
      if (text.contains(keyword)) {
        matched = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _messages.add({
              "text": autoReplies[keyword]!,
              "isMine": false,
              "timestamp": DateTime.now(),
            });
          });
          _scrollToBottom(); // ⬅️ 약사 응답 후 스크롤
        });
        break;
      }
    }

    if (!matched) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add({
            "text": "죄송해요, 해당 내용은 확인 후 다시 안내드릴게요 😊",
            "isMine": false,
            "timestamp": DateTime.now(),
          });
        });
        _scrollToBottom(); // ⬅️ 기본 응답 후 스크롤
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: Sizes.size8,
          leading: const CircleAvatar(
            radius: Sizes.size24,
            backgroundImage: AssetImage('assets/images/pharmacy.png'),
          ),
          title: const Text(
            '조은약국',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Active now'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.flag,
                color: Theme.of(context).iconTheme.color,
                size: Sizes.size20,
              ),
              Gaps.h32,
              FaIcon(
                FontAwesomeIcons.ellipsis,
                color: Theme.of(context).iconTheme.color,
                size: Sizes.size20,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.size20,
                horizontal: Sizes.size14,
              ),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => Gaps.v10,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMine = message['isMine'] as bool;
                final timestamp = message['timestamp'] as DateTime;
                final formattedTime = DateFormat('HH:mm').format(timestamp);

                final avatar = CircleAvatar(
                  radius: Sizes.size20,
                  backgroundImage: AssetImage(
                    isMine
                        ? "assets/images/avatar.png"
                        : "assets/images/pharmacy.png",
                  ),
                );

                final chatBubble = Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.all(Sizes.size14),
                  decoration: BoxDecoration(
                    color:
                        isMine ? Colors.blue : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(Sizes.size20),
                      topRight: const Radius.circular(Sizes.size20),
                      bottomLeft: Radius.circular(
                        isMine ? Sizes.size20 : Sizes.size5,
                      ),
                      bottomRight: Radius.circular(
                        !isMine ? Sizes.size20 : Sizes.size5,
                      ),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: Sizes.size16,
                    ),
                  ),
                );

                final bubbleWithTime = Column(
                  crossAxisAlignment:
                      isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    chatBubble,
                    Gaps.v4,
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children:
                      isMine
                          ? [bubbleWithTime, Gaps.h10, avatar]
                          : [avatar, Gaps.h10, bubbleWithTime],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size16,
              vertical: Sizes.size12,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                Gaps.h10,
                GestureDetector(
                  onTap: _sendMessage,
                  child: const FaIcon(FontAwesomeIcons.paperPlane),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
