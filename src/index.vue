<template>
  <div class="wrapper" @swipe="onSwipe" @click="onClick" @panstart="onPanstart" @panend="onPanend" @horizontalpan="onHorizontalpan">
      <image class="i-banner" resize="contain" src="http://doc.zwwill.com/justdo8/img/banner.png?t"></image>
      <text style="color:#fff;">{{actiontp}}</text>
      <text style="color:#fff;">{{sliderMove}},{{actionSize}}</text>
      <stoneMap ref="stoneMap" class="stone-map" @screenLock="onScreenLock" @screenUnlock="onScreenUnlock" @over="onGameoverk"></stoneMap>
  </div>
</template>
<style>
    body,html{
        margin: 0;
        height: 100%;
    }
</style>
<style scoped>
    .wrapper {
        background-image: linear-gradient(to top,#000,#333);
        padding-top: 20px;
        display: flex;
        flex-wrap: nowrap;
        flex-direction: column;
    }
    .i-banner{
        width: 400px;
        height: 100px;
    }
    .stone-map{
        position: relative;
        flex: 1;
    }
</style>

<script>

    var modal = weex.requireModule('modal');
    import stoneMap from '../assets/components/stoneMap.vue';
    export default {
        components: {
            stoneMap: stoneMap
        },
        data: {
            actiontp: 'action',
            actionStart:"*",
            actionTo:"*",
            actionSize:0,
            sliderMove:"",
            allAction:["click", "up", "down", "left", "right"]                              //指令白名单
        },
        methods: {
            onClick(e) {
                this.actiontp = "click";
                this.actionLaunch("click")
            },
            /**
             * 手势：上下滑动
             * */
            onSwipe(e) {
                this.actiontp = "swipe:" + e.direction;
                this.actionLaunch(e.direction)
            },
            /**
             * 手势：轻触滑动开始
             * */
            onPanstart(e) {
                this.actionStart=e.changedTouches[0].screenX;
            },
            /**
             * 手势：轻触滑动结束
             * */
            onPanend(e) {
                this.actionTo = this.actionStart = this.actionSize = 0;
            },
            /**
             * 手势：水平滑动
             * */
            onHorizontalpan(e) {
                if(this.actionStart==0) return;
                this.actiontp = "horizontalpan";
                this.actionTo = e.changedTouches[0].screenX
                this.actionSize = this.actionTo - this.actionStart;
                if(this.actionSize >= 40){
                    this.sliderMove = 'right';
                    this.actionStart = this.actionTo;
//                    modal.toast({message:"Slider Right",duration:0.1});
                    this.actionLaunch("right");

                }else if(this.actionSize <= -40){
                    this.sliderMove = 'left';
                    this.actionStart = this.actionTo;
//                    modal.toast({message:"Slider Left",duration:0.1});
                    this.actionLaunch("left");

                }
            },
            onScreenLock(e) {
                this.ScreenLock = true;
//                modal.toast({message:"ActionLock",duration:0.1});
            },
            onScreenUnlock(e) {
                this.ScreenLock = false;
//                modal.toast({message:"ActionUnlock",duration:0.1});
            },
            onGameoverk(e) {
                modal.toast({message:"Game Over",duration:1});
            },
            actionLaunch(_action){
                !this.ScreenLock && this.allAction.indexOf(_action)!=-1 && this.$refs.stoneMap.action(_action)
            }
        }
    }
</script>