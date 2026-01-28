
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_common/components/component_options/tencent_cloud_chat_message_options.dart';
import 'package:tencent_cloud_chat_common/components/tencent_cloud_chat_components_utils.dart';
import 'package:tencent_cloud_chat_common/cross_platforms_adapter/tencent_cloud_chat_screen_adapter.dart';
import 'package:tencent_cloud_chat_common/data/theme/color/color_base.dart';
import 'package:tencent_cloud_chat_common/data/theme/text_style/text_style.dart';
import 'package:tencent_cloud_chat_common/router/tencent_cloud_chat_navigator.dart';
import 'package:tencent_cloud_chat_common/tencent_cloud_chat.dart';
import 'package:tencent_cloud_chat_common/utils/tencent_cloud_chat_utils.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';
import 'package:tencent_cloud_chat_common/builders/tencent_cloud_chat_common_builders.dart';
import 'package:tencent_cloud_chat_common/utils/face_manager.dart';
import 'package:tencent_cloud_chat_common/widgets/avatar/tencent_cloud_chat_avatar.dart';
import 'package:tencent_cloud_chat_common/widgets/gesture/tencent_cloud_chat_gesture.dart';
import 'package:tencent_cloud_chat_conversation/src/model/tencent_cloud_chat_conversation_presenter.dart';

class TencentCloudChatConversationItem extends StatefulWidget {

  const TencentCloudChatConversationItem({
    required this.conversation,
    required this.isOnline,
    super.key,
    this.isSelected = false,
  });
  final V2TimConversation conversation;
  final bool isOnline;
  final bool isSelected;

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationItemState();
}

class TencentCloudChatConversationItemState extends TencentCloudChatState<TencentCloudChatConversationItem> {
  final bool useDesktopMode =
      (TencentCloudChat.instance.dataInstance.conversation.conversationConfig.useDesktopMode) &&
          (TencentCloudChatScreenAdapter.deviceScreenType == DeviceScreenType.desktop);
  TencentCloudChatConversationPresenter conversationPresenter = TencentCloudChatConversationPresenter();

  Future<void> _navigateToMessage() async {
    final options = TencentCloudChatMessageOptions(
      userID: widget.conversation.groupID == null ? widget.conversation.userID : null,
      groupID: widget.conversation.groupID,
      draftText: widget.conversation.draftText,
    );

    final res =
        await TencentCloudChat
            .instance
            .dataInstance
            .conversation
            .conversationEventHandlers
            ?.uiEventHandlers
            .onTapConversationItem
            ?.call(
          conversation: widget.conversation,
          messageOptions: options,
          inDesktopMode: useDesktopMode,
        ) ??
            false;
    if (res) {
      return;
    }

    if (useDesktopMode &&
        TencentCloudChat.instance.dataInstance.basic.usedComponents.contains(TencentCloudChatComponentsEnum.message)) {
      // Desktop combined navigator
      TencentCloudChat.instance.dataInstance.conversation.currentConversation = widget.conversation;
    } else if (TencentCloudChat.instance.dataInstance.basic.usedComponents.contains(
      TencentCloudChatComponentsEnum.message,
    )) {
      // Mobile navigator
      await navigateToMessage(
        context: context,
        options: options,
      );
    } else {
      // Custom onTap event
    }
  }

  bool isPin() {
    return widget.conversation.isPinned ?? false;
  }

  Widget conversationInner(TencentCloudChatThemeColors colors) {
    final pinned = isPin();

    return Ink(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(8, 0, 0, 0),
          ),
        ),
        color: colors.conversationItemNormalBgColor,
        // color: widget.isSelected
        //     ? colors.primaryColor.withValues(alpha: 0.05)
        //     : (pinned ? colors.conversationItemIsPinedBgColor : colors.conversationItemNormalBgColor),
      ),
      child: TencentCloudChatGesture(
        onTap: _navigateToMessage,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: getHeight(12),
            horizontal: getWidth(8),
          ),
          child: Row(
            children: [
              TencentCloudChat.instance.dataInstance.conversation.conversationBuilder?.getConversationItemAvatarBuilder(
                widget.conversation,
                widget.isOnline,
              )
              as Widget,
              TencentCloudChat.instance.dataInstance.conversation.conversationBuilder
                  ?.getConversationItemContentBuilder(
                widget.conversation,
              )
              as Widget,
              TencentCloudChat.instance.dataInstance.conversation.conversationBuilder?.getConversationItemInfoBuilder(
                widget.conversation,
              )
              as Widget,
            ],
          ),
        ),
      ),
    );
  }

  bool _isHidden() {
    // V2TIM_CONVERSATION_MARK_TYPE_HIDE = 0x1 << 3
    return widget.conversation.markList?.contains(8) ?? false;
  }

  @override
  Widget desktopBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (ctx, colors, fontSize) => conversationInner(colors),
    );
  }

  @override
  Widget tabletAppBuilder(BuildContext context) {
    return defaultBuilder(context);
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return _isHidden()
        ? const SizedBox()
        : TencentCloudChatThemeWidget(
      build: (ctx, colors, fontSize) => conversationInner(colors),
    );
  }
}

class TencentCloudChatConversationItemAvatar extends StatefulWidget {

  const TencentCloudChatConversationItemAvatar({
    required this.conversation,
    required this.isOnline,
    super.key,
  });
  final V2TimConversation conversation;
  final bool isOnline;

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationItemAvatarState();
}

class TencentCloudChatConversationItemAvatarState
    extends TencentCloudChatState<TencentCloudChatConversationItemAvatar> {
  List<String> getAvatar() {
    return [widget.conversation.faceUrl ?? ''];
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    final isDesktop = TencentCloudChatScreenAdapter.deviceScreenType == DeviceScreenType.desktop;
    final avatarSize = 48.0;
    return TencentCloudChatThemeWidget(
      build: (ctx, colors, fonts) => Padding(
        padding: EdgeInsets.only(
            left: 8,
            right: 12,
        ),
        child: SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: TencentCloudChatCommonBuilders.getCommonAvatarBuilder(
                  imageList: getAvatar(),
                  width: avatarSize,
                  height: avatarSize,
                  borderRadius: 100,
                  scene: TencentCloudChatAvatarScene.conversationList,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: SizedBox(
                  width: getSquareSize(isDesktop ? 9 : 10),
                  height: getSquareSize(isDesktop ? 9 : 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isOnline ? colors.conversationItemUserStatusBgColor : Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          getSquareSize(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TencentCloudChatConversationItemContent extends StatefulWidget {

  const TencentCloudChatConversationItemContent({
    required this.conversation,
    super.key,
  });
  final V2TimConversation conversation;

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationItemContentState();
}

class TencentCloudChatConversationItemContentState
    extends TencentCloudChatState<TencentCloudChatConversationItemContent> {
  String getDraftText() {
    var draft = '';
    if (widget.conversation.draftText != null) {
      draft = widget.conversation.draftText!;
    }
    if (draft.isNotEmpty) {
      draft = '[${tL10n.draft}]$draft';
    }
    return draft;
  }

  Widget getLastMessageStatus(TencentCloudChatThemeColors colorTheme) {
    Widget? wid;
    if (widget.conversation.lastMessage != null) {
      final message = widget.conversation.lastMessage!;
      if (message.status == 1) {
        // sending
        wid = Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            Icons.arrow_circle_left,
            size: getSquareSize(14),
            color: colorTheme.conversationItemSendingIconColor,
          ),
        );
      }
      if (message.status == 3) {
        // failed
        wid = Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            Icons.error_rounded,
            size: getSquareSize(14),
            color: colorTheme.conversationItemSendFailedIconColor,
          ),
        );
      }
    }
    wid ??= Container();
    return wid;
  }

  Widget getDraftWidget(TencentCloudChatTextStyle textStyle, TencentCloudChatThemeColors colorTheme) {
    final draft = getDraftText();
    final Widget draftWidget = draft.isEmpty
        ? Container()
        : Text(
      draft,
      style: TextStyle(
        color: colorTheme.conversationItemDraftTextColor,
        fontSize: textStyle.fontsize_14,
        fontWeight: FontWeight.w400,
      ),
    );
    return draftWidget;
  }

  Widget getLastMessageWidget(TencentCloudChatTextStyle textStyle, TencentCloudChatThemeColors colorTheme) {
    final laseMessage = widget.conversation.lastMessage;
    final originalText = TencentCloudChatUtils.getMessageSummary(
      message: laseMessage,
      messageReceiveOption: widget.conversation.recvOpt,
      unreadCount: widget.conversation.unreadCount,
      draftText: widget.conversation.draftText,
    );

    final replaceText = FaceManager.emojiMap.keys.fold(originalText, (previous, key) {
      return previous.replaceAll(key, FaceManager.emojiMap[key]!);
    });

    return Expanded(
      child: Text(
        replaceText,
        style: TextStyle(
          fontSize: textStyle.fontsize_14,
          fontWeight: FontWeight.w400,
          color: colorTheme.conversationItemLastMessageTextColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  int? _getShowAtType(List<V2TimGroupAtInfo> mentionedInfoList) {
    // 1 TIM_AT_ME = 1
    // 2 TIM_AT_ALL = 2
    // 3 TIM_AT_ALL_AT_ME = 3
    int? atType;
    if (mentionedInfoList.isNotEmpty) {
      atType = mentionedInfoList.first.atType;
      for (var info in mentionedInfoList.skip(1)) {
        if (info.atType != atType) {
          atType = 3;
          break;
        }
      }
    }

    return atType;
  }

  Widget getGroupAtInfo(TencentCloudChatTextStyle textStyle, TencentCloudChatThemeColors colorTheme) {
    final tips = <Widget>[];

    final style = TextStyle(
      color: colorTheme.conversationItemGroupAtInfoTextColor,
      fontSize: textStyle.fontsize_12,
      fontWeight: FontWeight.w400,
    );
    if (widget.conversation.groupAtInfoList != null) {
      if (widget.conversation.groupAtInfoList!.isNotEmpty) {
        final mentionedInfoList = <V2TimGroupAtInfo>[];

        for (var element in widget.conversation.groupAtInfoList!) {
          if (element != null) {
            mentionedInfoList.add(element);
          }
        }

        final atType = _getShowAtType(mentionedInfoList);
        if (atType != null) {
          var atTips = '';
          switch (atType) {
            case 1:
              atTips = '[${tL10n.atMeTips}] ';
              break;
            case 2:
              atTips = '[${tL10n.atAllTips}] ';
              break;
            case 3:
              atTips = '[${tL10n.atAllTips}] [${tL10n.atMeTips}] ';
              break;
            default:
              print('error: invalid atType!');
              break;
          }

          if (atTips.isNotEmpty) {
            tips.add(
              Text(
                atTips,
                style: style,
              ),
            );
          }
        }
      }
    }
    if (tips.isNotEmpty) {
      return Row(
        children: tips,
      );
    } else {
      return Container();
    }
  }


  @override
  Widget defaultBuilder(BuildContext context) {
    return Expanded(
      child: TencentCloudChatThemeWidget(
        build: (context, colorTheme, textStyle) {
          final status = getLastMessageStatus(colorTheme);
          final draft = getDraftWidget(textStyle, colorTheme);
          final lastMessage = getLastMessageWidget(textStyle, colorTheme);
          final mentionedInfo = getGroupAtInfo(textStyle, colorTheme);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                widget.conversation.showName ?? widget.conversation.conversationID,
                style: TextStyle(
                  fontSize: textStyle.fontsize_16,
                  fontWeight: FontWeight.w600,
                  color: colorTheme.conversationItemShowNameTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  draft,
                  status,
                  mentionedInfo,
                  lastMessage,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class TencentCloudChatConversationItemInfoUnreadCount extends StatefulWidget {

  const TencentCloudChatConversationItemInfoUnreadCount({required this.conversation, super.key});
  final V2TimConversation conversation;

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationItemInfoUnreadCountState();
}

class TencentCloudChatConversationItemInfoUnreadCountState
    extends TencentCloudChatState<TencentCloudChatConversationItemInfoUnreadCount> {
  bool hasUnreadCount() {
    var has = false;
    if (widget.conversation.unreadCount != null) {
      if (widget.conversation.unreadCount! > 0) {
        has = true;
      }
    }
    return has;
  }

  String unReadCountDisplayText() {
    var text = '';
    final count = widget.conversation.unreadCount ?? 0;
    if (count > 99) {
      text = '99+';
    } else {
      text = '$count';
    }
    return text;
  }

  Widget unreadCountWidget(BuildContext context, TencentCloudChatThemeColors colorTheme, TencentCloudChatTextStyle textStyle) {
    final text = unReadCountDisplayText();
    return Container(
      height: getHeight(16),
      width: text.length == 1 ? getWidth(16) : getWidth(26),
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        color: colorTheme.conversationItemUnreadCountBgColor,
        borderRadius: BorderRadius.all(
          Radius.circular(
            getSquareSize(8),
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getFontSize(10),
            fontWeight: FontWeight.w600,
            color: colorTheme.conversationItemUnreadCountTextColor,
          ),
        ),
      ),
    );
  }

  Widget noUnreadPlaceHolderWidget() {
    return SizedBox(
      height: getHeight(16),
    );
  }

  Widget notificationOffWidget(TencentCloudChatThemeColors colorTheme) {
    return Icon(
      Icons.notifications_off,
      size: getSquareSize(14),
      color: colorTheme.conversationItemNoReceiveIconColor,
    );
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    final hasUnread = hasUnreadCount();
    final receiveOption = widget.conversation.recvOpt ?? 0;
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) {
        if (receiveOption != 0) {
          return notificationOffWidget(colorTheme);
        } else {
          if (hasUnread) {
            return unreadCountWidget(context, colorTheme, textStyle);
          } else {
            return noUnreadPlaceHolderWidget();
          }
        }
      },
    );
  }
}

class TencentCloudChatConversationItemInfoTimeAndStatus extends StatefulWidget {

  const TencentCloudChatConversationItemInfoTimeAndStatus({
    required this.conversation,
    super.key,
  });
  final V2TimConversation conversation;

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationItemInfoTimeAndStatusState();
}

class TencentCloudChatConversationItemInfoTimeAndStatusState
    extends TencentCloudChatState<TencentCloudChatConversationItemInfoTimeAndStatus> {
  bool hasLastMessage() {
    return widget.conversation.lastMessage != null;
  }

  String getLastMessageTimeText() {
    var text = '';
    if (widget.conversation.lastMessage != null) {
      if (widget.conversation.lastMessage!.timestamp != null) {
        text = TencentCloudChatIntl.formatTimestampToHumanReadable(
          widget.conversation.lastMessage!.timestamp!,
          context,
        );
      }
    }
    return text;
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    final timeText = getLastMessageTimeText();
    if (!hasLastMessage()) {
      return Container();
    }
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            timeText,
            style: TextStyle(
              fontSize: textStyle.fontsize_12,
              fontWeight: FontWeight.w400,
              color: colorTheme.conversationItemTimeTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TencentCloudChatConversationItemInfo extends StatefulWidget {

  const TencentCloudChatConversationItemInfo({
    required this.conversation,
    super.key,
  });
  final V2TimConversation conversation;

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationItemInfoState();
}

class TencentCloudChatConversationItemInfoState extends TencentCloudChatState<TencentCloudChatConversationItemInfo> {
  @override
  Widget defaultBuilder(BuildContext context) {
    return SizedBox(
      width: getWidth(96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TencentCloudChatConversationItemInfoTimeAndStatus(
            conversation: widget.conversation,
          ),
          TencentCloudChatConversationItemInfoUnreadCount(
            conversation: widget.conversation,
          ),
        ],
      ),
    );
  }
}