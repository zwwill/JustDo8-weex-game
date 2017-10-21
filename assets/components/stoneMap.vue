<template>
    <div class="u-slider">
        <div class="u-score-b b2">
            <text class="u-score-tlt">HIGH</text>
            <text class="u-score">{{highScore>totalScore?highScore:totalScore}}</text>
        </div>
        <div class="u-score-b">
            <text class="u-score-tlt">SCORE</text>
            <text :class="['u-score',totalScore>highScore?'clr-green':'']" ref="rScore">{{totalScore}}</text>
        </div>
        <template v-for="i in stones">
            <stone :ref="i.id" :id="i.id" :p0="i.p0" :num0="i.s"></stone>
        </template>
    </div>
</template>

<script>

    const storage = weex.requireModule('storage');
    const animation = weex.requireModule('animation');
    import stone from './stone.vue';
    import Nat from 'natjs';
    export default {
        components: {
            stone: stone
        },
        data() {
            return {
                MAX_H: 9,
                totalScore: 0,
                highScore: 0,
                stones: [],
                map: [],
                sliderIndex: 1,
                actionLock: true,
                sNum: 0,
                sounds: {
                    change: {name:'change.wav'},
                    down: {name:'down.wav'},
                    over: {name:'over.wav'}
                }
            }
        },
        mounted() {
            this.map = [];
            this.stones = [];
            for (let _i = 0; _i < this.MAX_H; _i++) {
                this.map.push(['', '', '', '', '', '']);
            }
            this.pushStones();
            storage.getItem('H-SCORE', event => {
                if (event && event.data && event.data != "undefined") {
                    this.highScore = parseInt(event.data);
                } else {
                    this.highScore = 0;
                }
            });
            // 获取音频
            const bundleUrl = this.$getConfig().bundleUrl;
            this.sounds.change.url = this.setBundleUrl(bundleUrl, this.sounds.change.name);
            this.sounds.down.url = this.setBundleUrl(bundleUrl, this.sounds.down.name);
            this.sounds.over.url = this.setBundleUrl(bundleUrl, this.sounds.over.name);
        },
        methods: {
            /**
             * 事件控制
             * */
            action(_action) {
                if (!!this.actionLock) return;
                switch (_action) {
                    case 'click':
                    case 'up':
                        this.actionChange();
                        this.actionLock = true;
                        setTimeout(() => {
                            this.actionLock = false;
                        }, 200);
                        break;
                    case 'left':
                    case 'right':
                        this.actionSliderMove(_action);
                        this.actionLock = true;
                        setTimeout(() => {
                            this.actionLock = false;
                        }, 200);
                        break;
                    case 'down':
                    case 'bottom':
                        this.actionDown();
                        this.actionLock = true;
                        break;
                    default:

                }
            },
            /**
             * 新增三个单元块
             * */
            pushStones() {
                let _ps = [], _id;
                this.sliderIndex = Math.floor(Math.random() * 4);
                for (let i = 0; i < 3; i++) {
                    _id = 's' + (++this.sNum) + Date.now();
                    _ps.push({
                        id: _id,
                        p0: this.sliderIndex + i + ',' + (this.MAX_H - 1),
                        s: Math.floor(Math.random() * 1.5) + 1
                    });
                    this.map[0][this.sliderIndex + i] = _id;
                }
                this.stones.push(..._ps);
                this.actionLock = false;
            },
            /**
             * 滑块切换
             * */
            actionChange() {
                this.music(this.sounds.change.url);
                let _id1 = this.map[0][this.sliderIndex],
                    _id2 = this.map[0][this.sliderIndex + 1],
                    _id3 = this.map[0][this.sliderIndex + 2];

                this.sChange(_id1, {x: 2});
                this.map[0][this.sliderIndex + 2] = _id1;
                this.sChange(_id2, {x: -1});
                this.map[0][this.sliderIndex] = _id2;
                this.sChange(_id3, {x: -1});
                this.map[0][this.sliderIndex + 1] = _id3;
            },
            /**
             * 滑块左右滚动
             * */
            actionSliderMove(_d) {
                if (this.sliderIndex <= 0 && _d == 'left' || this.sliderIndex >= 3 && _d == 'right') return;
                let _id1 = this.map[0][this.sliderIndex],
                    _id2 = this.map[0][this.sliderIndex + 1],
                    _id3 = this.map[0][this.sliderIndex + 2],
                    _addend = _d == 'left' ? -1 : 1;

                this.sChange(_id1, {x: _addend});
                this.map[0][this.sliderIndex + _addend] = _id1;
                this.sChange(_id2, {x: _addend});
                this.map[0][this.sliderIndex + _addend + 1] = _id2;
                this.sChange(_id3, {x: _addend});
                this.map[0][this.sliderIndex + _addend + 2] = _id3;

                this.map[0][this.sliderIndex + 1 + _addend * -1] = "";
                this.sliderIndex += _addend;

            },
            /**
             * 单元块位置移动+权重加码
             * */
            actionDown() {
                this.$emit('screenLock');
                this.music(this.sounds.down.url);
                let _id, _x, _y, _res = [],
                    height = this.map.length - 1;
                for (let i = 0; i < 3; i++) {
                    _y = "";
                    _x = this.sliderIndex + i;
                    _id = this.map[0][_x];
                    for (let j = height; j > 0; j--) {
                        if (!this.map[j][_x]) {
                            _y = j;
                            break;
                        }
                    }
                    _y > 0 && _res.push([_id, _x, _y]);
                }
                if (_res && _res.length > 0) {
                    for (let p = 0; p < _res.length; p++) {
                        this.sChange(_res[p][0], _res[p][1] + ',' + _res[p][2]);
                        this.map[_res[p][2]][_res[p][1]] = _res[p][0];
                        this.map[0][_res[p][1]] = '';
                    }
                    this.mapUpdate();
                }
            },
            scorePlus: function (_s) {
                if (this.totalScore + parseInt(_s) > this.highScore) {
                    animation.transition(this.$refs['rScore'], {
                        styles: {
                            transform: 'scale(1.2)',
                            transformOrigin: '100%'
                        },
                        duration: 100,
                        timingFunction: 'ease-out',
                        delay: 0
                    }, () => {
                        setTimeout(() => {
                            animation.transition(this.$refs['rScore'], {
                                styles: {
                                    transform: ''
                                },
                                duration: 100,
                                timingFunction: 'ease-in',
                                delay: 0
                            }, () => {
                            });
                        }, 100)
                    });
                }
                this.totalScore += parseInt(_s) || 0;
            },
            /**
             * 重新计算map并更新
             * */
            mapUpdate() {
                this.mapCalculator(this.map);
            },/**
             * 计算map
             * */
            mapCalculator: (function () {
                var updateStone = function (_stones, _id, _s) {
                    /**
                     * 此方法控制得分规则
                     * 横竖对角线+1分
                     * 十字、X型+2分
                     * 8字型、9宫格分别+3分、+4分，当然，不可能存在这两种情况
                     * */
                    if (_stones[_id]) {
                        _s != 0 && _s < 8 && (_stones[_id]['score'] == 0 ? _stones[_id]['score'] = _s : _stones[_id]['score']++);
                    } else {
                        _stones[_id] = {
                            id: _id,
                            score: _s
                        }
                    }
                };

                return function (_map) {
                    let hasChange = false,
                        activeStones = {},
                        height = _map.length - 1,
                        width = _map[0].length - 1,
                        _tp_id, _s;
                    // 全逻辑网遍历
                    for (let y = height; y >= 0; y--) {
                        for (let x = 0; x <= width; x++) {
                            _tp_id = _map[y][x] || "";
                            // 排除四角
                            if (!_tp_id || (x == 0 || x == width) && (y == 0 || y == height)) continue;

                            _s = parseInt(this.$refs[_tp_id][0].num);
                            let _p1, _p2;
                            if (x == 0 || x == width || y == 0 || y == height) {
                                // 侧边，将其单独提炼出来是为了减少计算量三分之一的计算量
                                if (x == 0 || x == width) {
                                    // 竖排
                                    if (!_map[y - 1][x] || !_map[y + 1][x]) continue;
                                    _p1 = this.$refs[_map[y - 1][x]][0];
                                    _p2 = this.$refs[_map[y + 1][x]][0];
                                } else if (y == 0 || y == height) {
                                    // 横排
                                    if (!_map[y][x - 1] || !_map[y][x + 1]) continue;
                                    _p1 = this.$refs[_map[y][x - 1]][0];
                                    _p2 = this.$refs[_map[y][x + 1]][0];
                                }
                                if (_p1 && _p2 && _p1.num == _s && _p2.num == _s) {
                                    hasChange = true;
                                    updateStone(activeStones, _tp_id, ++_s);
                                    updateStone(activeStones, _p1.id, 0);
                                    updateStone(activeStones, _p2.id, 0);
                                }
                            } else {
                                // 中间可形成九宫格区域
                                const _map_matrix = [
                                    [[0, 1], [0, -1]],
                                    [[-1, 1], [1, -1]],
                                    [[-1, 0], [1, 0]],
                                    [[-1, -1], [1, 1]]
                                ];
                                for (let _i = 0, _mm; _i < _map_matrix.length; _i++) {
                                    _mm = _map_matrix[_i];
                                    if (!_map[y + _mm[0][0]][x + _mm[0][1]] || !_map[y + _mm[1][0]][x + _mm[1][1]]) continue;
                                    _p1 = this.$refs[_map[y + _mm[0][0]][x + _mm[0][1]]][0];
                                    _p2 = this.$refs[_map[y + _mm[1][0]][x + _mm[1][1]]][0];
                                    if (_p1 && _p2 && _p1.num == _s && _p2.num == _s) {
                                        hasChange = true;
                                        updateStone(activeStones, _tp_id, _s + 1);
                                        updateStone(activeStones, _p1.id, 0);
                                        updateStone(activeStones, _p2.id, 0);
                                    }
                                }
                            }
                        }
                    }

                    // 存在更新块
                    if (hasChange) {
                        setTimeout(() => {
                            for (let s in activeStones) {
                                this.sChange(s, undefined, activeStones[s].score);
                            }
                            this.music(this.sounds.change.url);
                            // 数字块整理
                            setTimeout(() => {
                                this.stonesTrim();
                            }, 100)
                        }, 400)
                    } else {
                        let _errorStone = "";
                        for (let _i = 0; _i < this.map[0].length; _i++) {
                            if (this.map[0][_i]) {
                                _errorStone = this.$refs[this.map[0][_i]][0].$refs['stone'];
                                break;
                            }
                        }
                        if (!!_errorStone) {
                            this.$emit('over', this.totalScore, this.highScore, _errorStone);
                            this.music(this.sounds.over.url,1);
                            if (this.totalScore > this.highScore) {
                                storage.setItem('H-SCORE', this.totalScore)
                            }
                        } else {
                            this.$emit('screenUnlock');
                            setTimeout(() => {
                                this.pushStones();
                            }, 100);
                        }
                    }
                }
            })(),
            /**
             * 整理数字块，堆积下降
             * */
            stonesTrim() {
                let hasChange = false,
                    height = this.map.length - 1,
                    width = this.map[0].length - 1,
                    _tp_id, _step = 0;
                for (let x = 0; x <= width; x++) {
                    _step = 0;
                    for (let y = height; y >= 0; y--) {
                        _tp_id = this.map[y][x] || "";
                        if (!_tp_id) {
                            _step++;
                            continue;
                        } else if (_step > 0) {
                            hasChange = true;
                            this.sChange(_tp_id, {y: _step});
                            this.map[y + _step][x] = _tp_id;
                            this.map[y][x] = "";
                        }
                    }
                }
                setTimeout(() => {
                    this.mapUpdate();
                }, hasChange ? 200 : 0);
            },
            /**
             * 单元块位置移动+权重加码
             * */
            sChange(_id, _p, _score) {
                let _tp = this.$refs[_id][0].p.split(','),
                    height = this.map.length - 1,
                    width = this.map[0].length - 1;
                if (typeof _p == 'string' && _p.split(',')) {
                    // 7-y 是为了翻转坐标
                    this.sMove(_id, _p.split(',')[0], height - parseInt(_p.split(',')[1]));
                } else if (typeof _p == 'object') {
                    !_p.x && (_p.x = 0);
                    !_p.y && (_p.y = 0);
                    (_p.x || _p.y) && this.sMove(_id, parseInt(_tp[0]) + _p.x, parseInt(_tp[1]) - _p.y);
                }
                _score >= 0 && this.sUp(_id, _score);
                _score == 0 && (this.map[height - parseInt(_tp[1])][parseInt(_tp[0])] = "");
            },
            /**
             * 单元块位置移动
             * */
            sMove(_id, _x, _y) {
                this.$refs[_id][0].move(_x, _y);
            },
            /**
             * 权重加码
             * */
            sUp(_id, _score) {
                this.$refs[_id][0].scoreChange(_score);
            },
            music(_url,_lock) {
                if(this.soundLock) return;
                Nat && Nat.audio.stop();
                Nat && Nat.audio.play(_url);
                if(_lock){
                    this.soundLock = true;
                    setTimeout(()=>{this.soundLock = false},19000);
                }
            },
            setBundleUrl(url, jsFile) {
                const bundleUrl = url;
                let host = '';
                let path = '';
                let nativeBase;
                const isAndroidAssets = bundleUrl.indexOf('your_current_IP') >= 0 || bundleUrl.indexOf('file://assets/') >= 0;
                const isiOSAssets = bundleUrl.indexOf('file:///') >= 0 && bundleUrl.indexOf('JustDo8.app') > 0;
                if (isAndroidAssets) {
                    nativeBase = 'file://assets/dist';
                } else if (isiOSAssets) {
                    // file:///var/mobile/Containers/Bundle/Application/{id}/JustDo8.app/
                    // file:///Users/{user}/Library/Developer/CoreSimulator/Devices/{id}/data/Containers/Bundle/Application/{id}/JustDo8.app/
                    nativeBase = bundleUrl.substring(0, bundleUrl.lastIndexOf('/') + 1);
                } else {
                    const matches = /\/\/([^\/]+?)\//.exec(bundleUrl);
                    const matchFirstPath = /\/\/[^\/]+\/([^\/]+)\//.exec(bundleUrl);
                    if (matches && matches.length >= 2) {
                        host = matches[1];
                    }
                    if (matchFirstPath && matchFirstPath.length >= 2) {
                        path = matchFirstPath[1];
                    }
                    nativeBase = 'http://' + host + '/';
                }
                const h5Base = './index.html?page=';
                // in Native
                let base = nativeBase;
                if (typeof navigator !== 'undefined' && (navigator.appCodeName === 'Mozilla' || navigator.product === 'Gecko')) {
                    // check if in weexpack project
                    if (path === 'web' || path === 'dist') {
                        base = h5Base + '/dist/';
                    } else {
                        base = h5Base + '';
                    }
                } else {
                    base = nativeBase + (!!path? path+'/':'');
                }

                const newUrl = base + jsFile;
                return newUrl;
            }
        }
    }
</script>

<style scoped>
    .u-score-b{
        position: fixed;
        width: 230px;
        top: 90px;
        right: 20px;
        display: flex;
        flex-direction: row;
        flex-wrap: nowrap;
    }
    .b2{
        top: 40px;
    }
    .u-score-tlt{
        height: 40px;
        color:#fff;
        font-size: 30px;
    }
    .u-score{
        height: 40px;
        flex: 1;
        font-size: 30px;
        text-align: right;
        color: #fff;
    }
    .clr-green{
        color: #3cd917;
    }
</style>
