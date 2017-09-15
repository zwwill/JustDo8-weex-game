<template>
  <div class="wrapper" @swipe="onSwipe" @click="onClick" @panstart="onPanstart" @horizontalpan="onHorizontalpan">
      <image class="i-banner" resize="contain" src="http://doc.zwwill.com/justdo8/img/banner.png?t"></image>
      <text style="color:#fff;">{{action}}</text>
      <text style="color:#fff;">{{actionStart+"->"+actionTo}}</text>
      <div class="stone-box">
          <stone p="27" num=1></stone>
      </div>
  </div>
</template>

<style scoped>
    .wrapper {
        background-color: #000;
        padding-top: 20px;
        display: flex;
        flex-wrap: nowrap;
        flex-direction: column;
    }
    .i-banner{
        width: 400px;
        height: 100px;
    }
    .stone-box{
        position: relative;
        flex: 1;
    }

</style>

<script>

    //              Nat.audio.play('http://cdn.instapp.io/nat/samples/audio.mp3',() => {
    //
    //              });
    import Nat from 'natjs';
    var modal = weex.requireModule('modal');
    import stone from '../assets/components/stone.vue';
    export default {
        components: {
            stone: stone
        },
        data: {
            action: 'action',
            actionSt:100,
            actionStart:"*",
            actionTo:"*"
        },
        methods: {
            onClick: function (e) {
                this.action = "click";
            },
            onSwipe: function (e) {
                this.action = "swipe:" + e.direction;
            },
            onPanstart: function (e) {
//                this.actionSt++;
                this.actionStart=e.changedTouches[0].screenX;
            },
            onHorizontalpan: function (e) {
                this.action = "horizontalpan";
                this.actionTo = e.changedTouches[0].screenX
            }
        }
    }
</script>