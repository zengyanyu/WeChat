import { TabBarClass } from '../viewmodel/tab'
import { Connect } from './Connect'
import Find from './Find'
import Mine from './Mine'
import WeChat from './Wechat'

@Entry
@Component
struct Index {
  @State
  tabList: TabBarClass[] = [
    {
      icon: $r('app.media.ic_public_message'),
      name: 'wechat',
      title: '微信',
      selectIcon: $r('app.media.ic_public_message_filled')
    }, {
    icon: $r('app.media.ic_public_contacts_group'),
    name: 'connect',
    title: '联系人',
    selectIcon: $r('app.media.ic_public_contacts_group_filled')
  }, {
    icon: $r('app.media.ic_gallery_discover'),
    name: 'discover',
    title: '发现',
    selectIcon: $r('app.media.ic_gallery_discover_filled')
  }, {
    icon: $r('app.media.ic_public_contacts'),
    name: 'my',
    title: '我的',
    selectIcon: $r('app.media.ic_public_contacts_filled')
  }]
  @State
  activeIndex: number = 0

  @Builder
  myTabBar(item: TabBarClass) {
    Column({ space: 4 }) {
      Image(this.tabList[this.activeIndex].name === item.name ? item.selectIcon : item.icon)
        .width(20)
        .height(20)
        .fillColor(this.tabList[this.activeIndex].name === item.name ?
        $r('app.color.primary') : $r('app.color.text_primary'))
      Text(item.title)
        .fontSize(12)
        .fontColor(this.tabList[this.activeIndex].name === item.name ?
        $r('app.color.primary') : $r('app.color.text_primary'))
    }
  }

  build() {
    Tabs({ index: $$this.activeIndex }) {
      ForEach(this.tabList, (item: TabBarClass) => {
        TabContent() {
          if (item.name === 'connect') {
            // 联系人组件
            Connect()
          } else if (item.name === 'wechat') {
            // 微信
            WeChat()
          } else if (item.name === 'my') {
            // 我的
            Mine()
          } else if (item.name === 'discover') {
            // 发现
            Find()
          }
        }
        .tabBar(this.myTabBar(item))
      })
    }
    .barPosition(BarPosition.End)
  }
}