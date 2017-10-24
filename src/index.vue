<template>
  <div class="wrapper" @swipe="onSwipe" @click="onClick" @panstart="onPanstart" @panend="onPanend" @horizontalpan="onHorizontalpan">
      <stoneMap v-if="stoneMapShow" ref="rStoneMap" class="stone-map" @screenLock="onScreenLock" @screenUnlock="onScreenUnlock" @over="onGameover" @win="onGameWin"></stoneMap>
      <text class="btn-start" ref="rBtnStart" @click="gameStart">START</text>
      <div class="u-info" v-if="infoShow">
          <text class="info-tlt">{{highScore?'FINAL SCORE':'RECORD BREAKING'}}</text>
          <text class="info-score">{{finalScore}}</text>
          <text class="info-high-s" v-if="highScore">HIGH SCORE: {{highScore}}</text>
          <text class="btn-restart" @click="gameRestart">RESTART</text>
      </div>
      <text class="tlt-win" v-if="win">YOU WIN !</text>
      <image class="i-banner" ref="rLogo" resize="contain" src="http://doc.zwwill.com/justdo8/img/banner.png"></image>

  </div>
</template>

<script>

    const animation = weex.requireModule('animation');
    import stoneMap from '../assets/components/stoneMap.vue';
    export default {
        components: {
            stoneMap: stoneMap
        },
        data: {
            stoneMapShow: false,
            infoShow: false,
            win:false,
            actionStart: 0,
            actionTo: 0,
            actionSize: 0,
            finalScore:0,
            highScore:0,
            allAction:["click", "up", "down", "left", "right"]                              //指令白名单
        },

        mounted(){
            setTimeout(()=>{
                animation.transition(this.$refs['rLogo'],{
                    styles: {
                        transform: 'translateY(200px) scale(1.4)',
                        opacity:1
                    },
                    duration: 800,
                    timingFunction: 'ease-out',
                    delay: 0
                },()=>{
                    animation.transition(this.$refs['rBtnStart'],{
                        styles: {
                            opacity:1
                        },
                        duration: 1000,
                        timingFunction: 'ease',
                        delay: 0
                    },_=>this.btnShine());
                });
            },1000);
        },
        methods: {
            btnShine(){
                !this.btnClock ? (this.btnClock = 1):this.btnClock ++;
                animation.transition(this.$refs['rBtnStart'],{
                    styles: {
                        opacity:this.btnClock%2==1?.5:1
                    },
                    duration: 800,
                    timingFunction: 'linear',
                    delay: 0
                },()=>{
                    if(!this.startBtnHide){
                        this.btnShine();
                    }else {
                        animation.transition(this.$refs['rBtnStart'],{
                            styles: {
                                opacity:0
                            },
                            duration: 400,
                            timingFunction: 'linear',
                            delay: 0
                        });
                    }
                });
            },
            gameStart(){
                this.startBtnHide = true;

                animation.transition(this.$refs['rLogo'],{
                    styles: {
                        transform: 'translate(-190px,-170px)',
                        opacity:1
                    },
                    duration: 1000,
                    timingFunction: 'ease-out',
                    delay: 0
                },()=>{
                    this.stoneMapShow = true;
                });
            },
            gameRestart() {
                this.finalScore = this.highScore = 0;
                this.stoneMapShow = true;
                this.infoShow = false;
                this.ScreenLock = false;
            },
            onGameover(s1,s2,_errorStone) {
                this.finalScore = s1;
                this.highScore = s1>s2?0:s2;
                this.ScreenLock = true;
                this._shineStone = _errorStone || "";
                this.stonesShine();
                setTimeout(()=>{
                    this.stoneMapShow = false;
                    this._shineStone = "";
                    this.infoShow = true;
                },3000);
            },
            onGameWin() {
                this.ScreenLock = true;
            },
            stonesShine(){
                !this.stonesShineClock ? (this.stonesShineClock = 1):this.stonesShineClock ++;
                if(!!this._shineStone) {
                        animation.transition(this._shineStone, {
                            styles: {
                                opacity: this.stonesShineClock % 2 == 1 ? .2 : 1
                            },
                            duration: 400,
                            timingFunction: 'linear',
                            delay: 0
                        }, () => this.stonesShine());
                }
            },
            onClick(e) {
                this.actionLaunch("click");
            },
            /**
             * 手势：上下滑动
             * */
            onSwipe(e) {
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
                this.actionTo = e.changedTouches[0].screenX
                this.actionSize = this.actionTo - this.actionStart;
                if(this.actionSize >= 40){
                    this.actionStart = this.actionTo;
                    this.actionLaunch("right");

                }else if(this.actionSize <= -40){
                    this.actionStart = this.actionTo;
                    this.actionLaunch("left");

                }
            },
            onScreenLock(e) {
                this.ScreenLock = true;
            },
            onScreenUnlock(e) {
                this.ScreenLock = false;
            },
            actionLaunch(_action){
                !this.ScreenLock && this.allAction.indexOf(_action)!=-1 && this.$refs.rStoneMap && this.$refs.rStoneMap.action(_action)
            }
        }
    }
</script>

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
        position: absolute;
        top: 200px;
        left: 175px;
        width: 400px;
        height: 100px;
        opacity: 0;
    }
    .btn-start{
        position: absolute;
        color: #3cd917;
        font-size: 50px;
        width: 300px;
        height: 80px;
        left: 225px;
        bottom: 300px;
        text-align: center;
        line-height: 80px;
        border-width: 1px;
        border-color: #3cd917;
        border-radius: 8px;
        background-color: rgba(0,0,0,0.8);
        box-shadow: 0 0 10px #fff;
        opacity: 0;
    }
    .stone-map{
        position: relative;
        flex: 1;
    }
    .u-info{
        position: absolute;
        top: 200px;
        height: 800px;
        width: 750px;
    }
    .tlt-win{
        position: fixed;
        top:150px;
        width: 750px;
        font-size: 70px;
        color:#fff;
        text-align: center;
        box-shadow: 0 0 10px #ff6616;
    }
    .info-tlt{
        margin-top: 50px;
        font-size: 70px;
        color:#fff;
        text-align: center;
    }
    .info-score{
        font-size: 100px;
        margin-top: 150px;
        margin-bottom: 130px;
        color:#3cd917;
        text-align: center;
    }
    .info-high-s{
        font-size: 40px;
        margin-bottom: 40px;
        color: #fbf00c;
        text-align: center;
    }
    .btn-restart{
        position: relative;
        color: #3cd917;
        font-size: 50px;
        width: 300px;
        height: 80px;
        top:100px;
        left: 400px;
        text-align: center;
        line-height: 80px;
        border-width: 1px;
        border-color: #3cd917;
        border-radius: 8px;
    }
</style>