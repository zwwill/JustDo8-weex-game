<template>
    <div class="u-slider">
        <template v-for="i in stones">
            <stone :ref="i.id" :id="i.id" :p0="i.p0" :num0="i.s"></stone>
        </template>
    </div>
</template>

<style scoped>
    .u-slider{

    }
</style>

<script>

    const modal = weex.requireModule('modal');
    import stone from './stone.vue';
    //import Nat from 'natjs';
    const EmptyMap = [
                ['', '', '', '', '', ''],
                ['', '', '', '', '', ''],
                ['', '', '', '', '', ''],
                ['', '', '', '', '', ''],
                ['', '', '', '', '', ''],
                ['', '', '', '', '', ''],
                ['', '', '', '', '', ''],
                ['', '', '', '', '', '']
            ];
    export default {
        components: {
            stone: stone
        },
        data(){
            return {
                stones:[],
                map: [
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', '']
                ],
                sliderIndex: 1,
                actionLock: false,
                sounds:{
                    change:'http://doc.zwwill.com/justdo8/res/change.wav'
                }
            }
        },
        mounted(){
            this.pushStones();
        },
        methods: {
            /**
             * 事件控制
             * */
            action(_action){
                if(!!this.actionLock) return;
                switch (_action){
                    case 'click':
                    case 'up':
                        this.actionChange();
                        break;
                    case 'left':
                    case 'right':
                        this.actionSliderMove(_action);
                        break;
                    case 'down':
                        this.actionDown();
                        break;
                    default:
                        modal.toast({message:'unknown action',duration:0.1});

                }
                this.actionLock = true;
                setTimeout(()=>{this.actionLock = false;},200);
            },
            /**
             * 新增三个单元块
             * */
            pushStones(){
                let _ps = [],_id;
                this.sliderIndex = Math.floor(Math.random()*4);
                for(let i=0;i<3;i++) {
                    _id = 's' + (Math.floor(Math.random() * 1000000) + Date.now());
                    _ps.push({
                        id: _id,
                        p0: this.sliderIndex + i + ',7',
                        s: Math.floor(Math.random() * 1.5) + 1
                    });
                    this.map[0][this.sliderIndex + i] = _id;
                }
                this.stones.push(..._ps);
            },
            /**
             * 滑块切换
             * */
            actionChange() {
                let _id1 = this.map[0][this.sliderIndex],
                    _id2 = this.map[0][this.sliderIndex + 1],
                    _id3 = this.map[0][this.sliderIndex + 2];

                this.sChange(_id1, {x:2});
                this.map[0][this.sliderIndex+2] = _id1;
                this.sChange(_id2, {x:-1});
                this.map[0][this.sliderIndex] = _id2;
                this.sChange(_id3, {x:-1});
                this.map[0][this.sliderIndex+1] = _id3;
            },
            /**
             * 滑块左右滚动
             * */
            actionSliderMove(_d){
                if(this.sliderIndex<=0 && _d=='left' || this.sliderIndex>=3 && _d=='right')return;
                let _id1 = this.map[0][this.sliderIndex],
                    _id2 = this.map[0][this.sliderIndex + 1],
                    _id3 = this.map[0][this.sliderIndex + 2],
                    _addend = _d=='left'? -1 : 1;

                this.sChange(_id1, {x:_addend});
                this.map[0][this.sliderIndex+_addend] = _id1;
                this.sChange(_id2, {x:_addend});
                this.map[0][this.sliderIndex+_addend+1] = _id2;
                this.sChange(_id3, {x:_addend});
                this.map[0][this.sliderIndex+_addend+2] = _id3;

                this.map[0][this.sliderIndex+1+_addend*-1] = "";
                this.sliderIndex += _addend;

            },
            /**
             * 单元块位置移动+权重加码
             * */
            actionDown(){
                this.$emit('screenLock');
                let _id,_x,_y,_res=[];
                for(let i=0 ; i<3 ; i++){
                    _y = "";
                    _id = this.map[0][this.sliderIndex+i];
                    _x = this.$refs[_id][0].p.split(',')[0];
                    for(let j=7;j>0;j--){
                        if(!this.map[j][_x]){
                            _y = j;
                            break;
                        }
                    }
                    _y>0 && _res.push([_id,_x,_y]);
                }
                if(_res && _res.length == 3){
                    for(let p=0 ; p<3 ; p++) {
                        this.map[_res[p][2]][_res[p][1]] = _res[p][0];
                        this.map[0][this.sliderIndex+p] = '';
                        this.sChange(_res[p][0], _res[p][1]+','+_res[p][2]);
                    }
                    this.mapUpdate();
                }else {
                    this.$emit('over');
                }
            },
            /**
             * 重新计算map并更新
             * */
            mapUpdate(){
                this.mapCalculator1(this.map);
            },
            /**
             * 计算map
             * */
            mapCalculator1:(function () {
                var updateStone = function(_stones,_id,_s) {
                    if(_stones[_id]){
                        _s != 0 && (_stones[_id]['score'] == 0 ? _stones[_id]['score'] = _s : _stones[_id]['score']++);
                    }else{
                        _stones[_id] = {
                            id: _id,
                            score: _s
                        }
                    }
                };
                return function (_map) {
                    // 新的空map 和 活动的stone
                    let hasChange=false,
                        activeStones={},
                        height = _map.length,
                        width = _map[0].length,
                        _tp_id,_p,_s;
                    for(let y = height-1; y>0;y--){
                        for(let x = 0; x<width; x++){
                            _tp_id = _map[y][x] || "";
                            if(!_tp_id || (x==0 || x==width-1) && (y==1 || y==height-1) ) continue;   //排除四角
                            // 循环遍历整个map
                            _p = this.$refs[_tp_id][0].p.split(',');
                            _s = parseInt(this.$refs[_tp_id][0].num);
                            let _p1,_p2,_px,_py;
                            if(x==0 || x==width-1 || y == 1 || y==height-1) {
                                //侧边
                                if (x == 0 || x == width - 1) {
                                    // 竖排
                                    _py = height - 1 - parseInt(_p[1]);
                                    if(!_map[_py - 1][x] || !_map[_py + 1][x]) continue;
                                    _p1 = this.$refs[_map[_py - 1][x]][0];
                                    _p2 = this.$refs[_map[_py + 1][x]][0];

                                } else if (y == 1 || y == height - 1) {
                                    // 横排
                                    _px = parseInt(_p[0]);
                                    if(!_map[y][_px - 1] || !_map[y][_px + 1]) continue;
                                    _p1 = this.$refs[_map[y][_px - 1]][0];
                                    _p2 = this.$refs[_map[y][_px + 1]][0];
                                }
                                if (_p1&&_p2&&_p1.num == _s && _p2.num == _s) {
                                    hasChange = true;
                                    updateStone(activeStones,_tp_id,++_s);
                                    updateStone(activeStones,_p1.id,0);
                                    updateStone(activeStones,_p2.id,0);
                                }
                            }else {
                                //中间九宫格区域
                                const _map_matrix = [
                                    [[0,1],[0,-1]],
                                    [[-1,1],[1,-1]],
                                    [[-1,0],[1,0]],
                                    [[-1,-1],[1,1]]
                                ];
                                _py = height - 1 - parseInt(_p[1]);
                                _px = parseInt(_p[0]);
                                for(let _i=0, _mm = _map_matrix[0] ; _i<_map_matrix.length ; _mm = _map_matrix[++_i]){
                                    if(!_map[_py + _mm[0][0]][_px + _mm[0][1]] || !_map[_py + _mm[1][0]][_px + _mm[1][1]]) continue;
                                    _p1 = this.$refs[_map[_py + _mm[0][0]][_px + _mm[0][1]]][0];
                                    _p2 = this.$refs[_map[_py + _mm[1][0]][_px + _mm[1][1]]][0];
                                    if (_p1&&_p2&&_p1.num == _s && _p2.num == _s) {
                                        hasChange = true;
                                        updateStone(activeStones,_tp_id,++_s);
                                        updateStone(activeStones,_p1.id,0);
                                        updateStone(activeStones,_p2.id,0);
                                    }
                                }
                            }
                        }
                    }

                    // 存在更新块
                    if(hasChange){
                        setTimeout(()=>{
                            for(let s in activeStones){
                                this.sChange(s,undefined,activeStones[s].score);
                            }
                            // 数字块整理
                            setTimeout(()=>{
                                this.stonesTrim();
                            },100)
                        },300)
                    }else{
                        this.$emit('screenUnlock');
                        setTimeout(()=>{this.pushStones();},100);
                    }
                }
            })(),
            /**
             * 整理数字块，堆积下降
             * */
            stonesTrim(){
                let hasChange = false,
                    height = this.map.length,
                    width = this.map[0].length,
                    _tp_id,_p_y,_step=0;
                for(let x = 0; x<width; x++){
                    _step = 0;
                    for(let y = height-1; y>0;y--){
                        _tp_id = this.map[y][x] || "";
                        if(!_tp_id){
                            _step ++;
                            continue;
                        }else if(_step>0){
                            hasChange = true;
                            _p_y = parseInt(this.$refs[_tp_id][0].p.split(',')[1]);
                            this.sChange(_tp_id, {y:_step});
                            this.map[height-1-_p_y+_step][x] = _tp_id;
                            this.map[y][x] = "";
                        }
                    }
                }
                setTimeout(()=>{
                    this.mapUpdate();
                },hasChange?300:0);
            },
            /**
             * 单元块位置移动+权重加码
             * */
            sChange(_id,_p,_score){
                let _tp = this.$refs[_id][0].p.split(',');
                if(typeof _p == 'string' && _p.split(',')) {
                    // 7-y 是为了翻转坐标
                    this.sMove(_id, _p.split(',')[0], 7-parseInt(_p.split(',')[1]));
                }else if(typeof _p == 'object'){
                    !_p.x && (_p.x=0);
                    !_p.y && (_p.y=0);
                    this.sMove(_id, parseInt(_tp[0])+_p.x , parseInt(_tp[1])-_p.y);
                }
                _score>=0 && this.sUp(_id,_score);
                _score == 0 && (this.map[7-parseInt(_tp[1])][parseInt(_tp[0])] = "");
            },
            /**
             * 单元块位置移动
             * */
            sMove(_id,_x,_y){
                this.$refs[_id][0].move(_x,_y);
            },
            /**
             * 权重加码
             * */
            sUp(_id,_score){
                this.$refs[_id][0].scoreChange(_score);
            },
            music(_res){
//                Nat.audio.play(_res);
            }
        }
    }
</script>