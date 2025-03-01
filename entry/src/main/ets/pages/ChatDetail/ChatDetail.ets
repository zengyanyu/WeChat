import { router } from '@kit.ArkUI'
import { AudioRender } from '../../utils/AudioRender'
import { AVPlayerClass } from '../../utils/AVPlayerClass'
import { requestMessage } from '../../utils/request'
import { StoreClass } from '../../utils/StoreClass'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../viewmodel/message'
import { currentUser, UserInfo } from '../../viewmodel/user'
import BottomInput from './BottomInput'
import Message from './Message'
import PreviewImage from './PreviewImage'

@Entry
@Component
struct ChatDetail {
  @State
  talker: UserInfo = {} as UserInfo
  @State
  messageList: MessageInfoModel[] = []
  @State
  isInputting: boolean = false
  // 预览的地址
  previewUrl: string = ''
  type: 'img' | 'video' = 'img'
  // 初始化：预览的弹层
  previewController: CustomDialogController = new CustomDialogController({
    builder: PreviewImage({
      url: this.previewUrl,
      type: this.type
    }),
    autoCancel: false,
    customStyle: true
  })

  // // 预览图片(打开弹层)
  // previewImage(){
  //   this.previewController.open()
  // }


  aboutToAppear(): void {
    this.talker = router.getParams() as UserInfo
    this.messageList = StoreClass.getChatMessage(this.talker.user_id)
    // 消息有了再去创建(更应该在entryAbility创建的时候进行初始化)
    AudioRender.init()
  }

  // 发送文本消息
  async sendTextMsg(message: string) {
    //   准备消息对象
    const newMessage = new MessageInfoModel({
      messageContent: message,
      sendUser: currentUser,
      connectUser: this.talker
    } as MessageInfo)
    //   加入消息列表中(视图上添加)
    this.messageList.push(newMessage)
    //   持久化
    await StoreClass.addChatMessage(this.talker.user_id, newMessage)
    // 滚动到底部
    this.scroller.scrollEdge(Edge.Bottom)
    //  获取消息结果
    this.getResponseMessage(message)
    //   音乐的播放
    AVPlayerClass.play('send')
  }

  // 发送语音消息
  async sendAudioMsg(filePath: string, duration: number) {
    const newMessage = new MessageInfoModel({
      messageContent: `[语音] ${duration}"`,
      sendUser: currentUser,
      connectUser: this.talker,
      messageType: MessageTypeEnum.AUDIO,
      sourceFilePath: filePath,
      sourceDuration: duration
    } as MessageInfo)
    //   加入消息列表中(视图上添加)
    this.messageList.push(newMessage)
    //   持久化
    await StoreClass.addChatMessage(this.talker.user_id, newMessage)
    // 滚动到底部
    this.scroller.scrollEdge(Edge.Bottom)
  }

  // 发送图片消息

  sendImageMsg(imgList: MessageInfoModel[]) {
    // ...可以用，但是只能给数组用
    this.messageList.push(...imgList)
    //   持久化
    imgList.forEach(async (newMessage) => {
      await StoreClass.addChatMessage(this.talker.user_id, newMessage)
    })
    // 滚动到底部
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 30)
    //   音乐的播放
    AVPlayerClass.play('send')
  }

  // 接收文本消息
  async getResponseMessage(message: string) {
    this.isInputting = true
    const result = await requestMessage(message)
    // result.data.info.text
    //   准备消息对象
    const newMessage = new MessageInfoModel({
      messageContent: result.data.info.text,
      // 后续数据持久化有关系
      sendUser: this.talker,
      // 这条消息是我跟谁聊得(归属者)
      // 判断这条消息的归属！！！
      connectUser: this.talker
    } as MessageInfo)
    //   加入消息列表中
    this.messageList.push(newMessage)
    //   持久化
    await StoreClass.addChatMessage(this.talker.user_id, newMessage)
    // 滚动到底部

    this.isInputting = false

    AVPlayerClass.play('information')
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 30)
  }

  // 删除UI页面消息
  delMessage(messageId: string) {
    const index = this.messageList.findIndex(message => message.id === messageId)
    this.messageList.splice(index, 1)
  }

  // 列表滚动控制器
  scroller: Scroller = new Scroller()

  // 全屏模态实现思路：预览图片
  // @Provide
  // showImageInfo:boolean = false
  // @Provide
  // previewImageUrl:string = ''
  // @Builder
  // getImageInfo(){
  //    Column(){
  //      Image(this.previewImageUrl)
  //        .width('100%')
  //    }.width('100%')
  //   .height('100%')
  //   .backgroundColor('#000')
  //   .justifyContent(FlexAlign.Center)
  // }


  build() {
    Column() {
      // 标题
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Text(this.isInputting ? '对方正在输入' : this.talker.username)
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
          Image($r('app.media.ic_public_arrow_left'))
            .width(30)
            .height(30)
            .onClick(() => {
              router.back()
            })
        }
        .height(50)
      }
      .padding({
        left: 10,
        right: 10
      })

      //   聊天内容
      List({ space: 16, scroller: this.scroller }) {
        ForEach(this.messageList, (message: MessageInfoModel) => {
          Message({
            message,
            delMessage: (messageId: string) => {
              this.delMessage(messageId)
            },
            previewImage: () => {
              // 1.设置预览地址
              this.previewUrl = message.sourceFilePath
              // -----判断是图片还是视频
              this.type = message.messageType === MessageTypeEnum.IMAGE ? 'img' : 'video'
              // 2.打开预览
              this.previewController.open()
            }
          })
        })
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.back_color'))
      .padding({
        top: 20
      })

      //   聊天框
      BottomInput({
        sendTextMsg: (message) => {
          this.sendTextMsg(message)
        },
        sendAudioMsg: (filePath, duration) => {
          this.sendAudioMsg(filePath, duration)
        },
        sendImageMsg: (imgList) => {
          this.sendImageMsg(imgList)
        },
        talker: this.talker
      })
    }
    .height('100%')

    // 全屏模态实现思路：
    // .bindContentCover(this.showImageInfo,this.getImageInfo,{
    //   modalTransition:ModalTransition.NONE
    // })
  }
}