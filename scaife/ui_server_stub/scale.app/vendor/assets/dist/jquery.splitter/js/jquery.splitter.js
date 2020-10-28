/*!
 * jQuery Spliter Plugin version 0.28.3
 * Copyright (C) 2010-2019 Jakub T. Jankiewicz <https://jcubic.pl/me>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/* global module, define, global, require, setTimeout */
// UMD taken from https://github.com/umdjs/umd
(function(factory, undefined) {
    var root = typeof window !== 'undefined' ? window : global;
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        // istanbul ignore next
        define(['jquery'], factory);
    } else if (typeof module === 'object' && module.exports) {
        // Node/CommonJS
        module.exports = function(root, jQuery) {
            if (jQuery === undefined) {
                // require('jQuery') returns a factory that requires window to
                // build a jQuery instance, we normalize how we use modules
                // that require this pattern but the window provided is a noop
                // if it's defined (how jquery works)
                if (window !== undefined) {
                    jQuery = require('jquery');
                } else {
                    jQuery = require('jquery')(root);
                }
            }
            factory(jQuery);
            return jQuery;
        };
    } else {
        // Browser
        // istanbul ignore next
        factory(root.jQuery);
    }
})(function($, undefined) {
    var count = 0;
    var splitter_id = null;
    var splitters = [];
    var current_splitter = null;
    var current_splitter_index = null;
    $.fn.split = function(options) {
        var data = this.data('splitter');
        if (data) {
            return data;
        }
        var panels = [];
        var $splitters = [];
        var panel_1;
        var panel_2;
        var settings = $.extend({
            limit: 100,
            orientation: 'horizontal',
            position: '50%',
            invisible: false,
            onDragStart: $.noop,
            onDragEnd: $.noop,
            onDrag: $.noop,
            percent: false
        }, options || {});
        this.settings = settings;
        var cls;
        var children = this.children();
        if (children.length === 2) {
            if (settings.orientation == 'vertical') {
                panel_1 = children.first().addClass('left_panel');
                panel_2 = panel_1.next().addClass('right_panel');
                cls = 'vsplitter';
            } else if (settings.orientation == 'horizontal') {
                panel_1 = children.first().addClass('top_panel');
                panel_2 = panel_1.next().addClass('bottom_panel');
                cls = 'hsplitter';
            }
            panels = [panel_1, panel_2];
        } else {
            children.each(function() {
                var panel = $(this);
                if (settings.orientation == 'vertical') {
                    panel.addClass('vertical_panel');
                    cls = 'vsplitter';
                } else {
                    panel.addClass('horizontal_panel');
                    cls = 'hsplitter';
                }
                panels.push(panel);
            });
        }
        if (settings.invisible) {
            cls += ' splitter-invisible';
        }
        var width = this.width();
        var height = this.height();
        this.addClass('splitter_panel');
        var id = count++;
        panels.slice(0, -1).forEach(function(panel, i) {
            var splitter = $('<div/>').addClass(cls).on('mouseenter touchstart', function() {
                splitter_id = id;
                current_splitter_index = splitter.index() - i - 1;
            }).on('mouseleave touchend', function() {
                splitter_id = null;
                current_splitter_index = null;
            }).insertAfter(panel);
            $splitters.push(splitter);
        });
        var position;

        function get_position(position) {
            if (position instanceof Array) {
                return position.map(get_position);
            }
            if (typeof position === 'number') {
                return position;
            }
            if (typeof position === 'string') {
                var match = position.match(/^([0-9\.]+)(px|%)$/);
                if (match) {
                    if (match[2] == 'px') {
                        return +match[1];
                    } else {
                        if (settings.orientation == 'vertical') {
                            return (width * +match[1]) / 100;
                        } else if (settings.orientation == 'horizontal') {
                            return (height * +match[1]) / 100;
                        }
                    }
                } else {
                    //throw position + ' is invalid value';
                }
            } else {
                //throw 'position have invalid type';
            }
        }

        function set_limit(limit) {
            if(!isNaN(parseFloat(limit)) && isFinite(limit)){
                return {
                    leftUpper: limit,
                    rightBottom: limit
                };
            }
            return limit;
        }

        var self = $.extend(this, {
            refresh: function() {
                var new_width = this.width();
                var new_height = this.height();
                if (width != new_width || height != new_height) {
                    width = this.width();
                    height = this.height();
                    self.position(position);
                }
            },
            option: function(name, value) {
                if (name === 'position') {
                    return self.position(value);
                } else if (typeof value === 'undefined') {
                    return settings[name];
                } else {
                    settings[name] = value;
                }
                return self;
            },
            position: (function() {
                function make_sizer(dim_name, pos_name) {
                    return function(n, silent) {
                        if (n === undefined) {
                            return position;
                        } else {
                            position = get_position(n);
                            if (!(position instanceof Array)) {
                                position = [position];
                            }
                            if (position.length !== panels.length - 1) {
                                throw new Error('position array need to equal splitters length');
                            }
                            var outer_name = 'outer';
                            outer_name += dim_name[0].toUpperCase() + dim_name.substring(1);
                            var dim_px = self.css('visiblity', 'hidden')[dim_name]();
                            var pw = 0;
                            var sw_sum = 0;
                            for (var i = 0; i < position.length; ++i) {
                                var splitter = $splitters[i];
                                var panel = panels[i];
                                var pos = position[i];
                                var splitter_dim = splitter[dim_name]();
                                var sw2 = splitter_dim/2;
                                if (settings.invisible) {
                                    pw += panel[dim_name](pos)[outer_name]();
                                    splitter.css(pos_name, pw - (sw2 * (i + 1)));
                                } else if (settings.percent) {
                                    var w1 = (pos - sw2) / dim_px * 100;
                                    var l1 = (pw + sw_sum) / dim_px * 100;
                                    panel.css(pos_name, l1 + '%');
                                    pw += panel.css(dim_name, w1 + '%')[outer_name]();
                                    splitter.css(pos_name, (pw + sw_sum) / dim_px * 100 + '%');
                                } else {
                                    panel.css(pos_name, pw + sw_sum);
                                    pw += panel.css(dim_name, pos - sw2)[outer_name]();
                                    splitter.css(pos_name, pw + sw_sum);
                                }
                                sw_sum += splitter_dim;
                            }
                            var panel_last = panels[i];
                            if (settings.invisible) {
                                panel_last.height(height - pw);
                            } else {
                                var s_sum = splitter_dim * i;
                                var props = {};
                                if (settings.percent) {
                                    props[dim_name] = (dim_px - pw - sw_sum) / dim_px * 100 + '%';
                                    props[pos_name] = (pw + sw_sum) / dim_px * 100 + '%';
                                } else {
                                    props[dim_name] = dim_px - pw - sw_sum;
                                    props[pos_name] = pw + sw_sum;
                                }
                                panel_last.css(props);
                            }
                            self.css('visiblity', '');
                        }
                        if (!silent) {
                            self.trigger('splitter.resize');
                            self.find('.splitter_panel').trigger('splitter.resize');
                        }
                        return self;
                    };
                }
                if (settings.orientation == 'vertical') {
                    return make_sizer('width', 'left');
                } else if (settings.orientation == 'horizontal') {
                    return make_sizer('height', 'top');
                } else {
                    return $.noop;
                }
            })(),
            _splitters: $splitters,
            _panels: panels,
            orientation: settings.orientation,
            limit: set_limit(settings.limit),
            isActive: function() {
                return splitter_id === id;
            },
            destroy: function() {
                self.removeClass('splitter_panel');
                if (settings.orientation == 'vertical') {
                    panel_1.removeClass('left_panel');
                    panel_2.removeClass('right_panel');
                } else if (settings.orientation == 'horizontal') {
                    panel_1.removeClass('top_panel');
                    panel_2.removeClass('bottom_panel');
                }
                self.off('splitter.resize');
                self.trigger('splitter.resize');
                self.find('.splitter_panel').trigger('splitter.resize');
                splitters[id] = null;
                count--;
                $splitters.each(function() {
                    var splitter = $(this);
                    splitter.off('mouseenter');
                    splitter.off('mouseleave');
                    splitter.off('touchstart');
                    splitter.off('touchmove');
                    splitter.off('touchend');
                    splitter.off('touchleave');
                    splitter.off('touchcancel');
                    splitter.remove();
                });
                self.removeData('splitter');
                var not_null = false;
                for (var i=splitters.length; i--;) {
                    if (splitters[i] !== null) {
                        not_null = true;
                        break;
                    }
                }
                //remove document events when no splitters
                if (!not_null) {
                    $(document.documentElement).off('.splitter');
                    $(window).off('resize.splitter');
                    splitters = [];
                    count = 0;
                }
            }
        });
        self.on('splitter.resize', function(e) {
            var pos = self.position();
            if (self.orientation == 'vertical' &&
                pos > self.width()) {
                pos = self.width() - self.limit.rightBottom-1;
            } else if (self.orientation == 'horizontal' &&
                       pos > self.height()) {
                pos = self.height() - self.limit.rightBottom-1;
            }
            if (pos < self.limit.leftUpper) {
                pos = self.limit.leftUpper + 1;
            }
            e.stopPropagation();
            self.position(pos, true);
        });
        //inital position of splitter
        var pos;
        if (settings.orientation == 'vertical') {
            if (pos > width-settings.limit.rightBottom) {
                pos = width-settings.limit.rightBottom;
            } else {
                pos = get_position(settings.position);
            }
        } else if (settings.orientation == 'horizontal') {
            //position = height/2;
            if (pos > height-settings.limit.rightBottom) {
                pos = height-settings.limit.rightBottom;
            } else {
                pos = get_position(settings.position);
            }
        }
        if (pos < settings.limit.leftUpper) {
            pos = settings.limit.leftUpper;
        }
        if (panels.length > 2 && !(pos instanceof Array && pos.length == $splitters.length)) {
            throw new Error('position need to be array equal to $splitters length');
        }
        self.position(pos, true);
        var parent = this.closest('.splitter_panel');
        if (parent.length) {
            this.height(parent.height());
        }
        function calc_pos(pos, x) {
            var new_pos = pos.slice(0, current_splitter.index);
            var p;
            if (new_pos.length) {
                p = x - new_pos.reduce(function(a, b) {
                    return a + b;
                });
            } else {
                p = x;
            }
            var diff = pos[current_splitter.index] - p;
            new_pos.push(p);
            if (current_splitter.index < pos.length - 1) {
                var rest = pos.slice(current_splitter.index + 1);
                rest[0] += diff;
                new_pos = new_pos.concat(rest);
            }
            return new_pos;
        }
        // ------------------------------------------------------------------------------------
        // bind events to document if no splitters
        if (splitters.filter(Boolean).length === 0) {
            $(window).on('resize.splitter', function() {
                $.each(splitters, function(i, splitter) {
                    if (splitter) {
                        splitter.refresh();
                    }
                });
            });
            $(document.documentElement).on('mousedown.splitter touchstart.splitter', function(e) {
                if (splitter_id !== null) {
                    e.preventDefault();
                    current_splitter = {
                        node: splitters[splitter_id],
                        index: current_splitter_index
                    };
                    // ignore right click
                    if (e.originalEvent.button !== 2) {
                        setTimeout(function() {
                            $('<div class="splitterMask"></div>').
                                css('cursor', current_splitter.node.children().eq(1).css('cursor')).
                                insertAfter(current_splitter.node);
                        });
                    }
                    current_splitter.node.settings.onDragStart(e);
                }
            }).on('mouseup.splitter touchend.splitter touchleave.splitter touchcancel.splitter', function(e) {
                if (current_splitter) {
                    setTimeout(function() {
                        $('.splitterMask').remove();
                    });
                    current_splitter.node.settings.onDragEnd(e);
                    current_splitter = null;
                }
            }).on('mousemove.splitter touchmove.splitter', function(e) {
                var pos;
                if (current_splitter !== null) {
                    var node = current_splitter.node;
                    var leftUpperLimit = node.limit.leftUpper;
                    var rightBottomLimit = node.limit.rightBottom;
                    var offset = node.offset();
                    if (node.orientation == 'vertical') {
                        var pageX = e.pageX;
                        if(e.originalEvent && e.originalEvent.changedTouches){
                          pageX = e.originalEvent.changedTouches[0].pageX;
                        }
                        var x = pageX - offset.left;
                        if (x <= node.limit.leftUpper) {
                            x = node.limit.leftUpper + 1;
                        } else if (x >= node.width() - rightBottomLimit) {
                            x = node.width() - rightBottomLimit - 1;
                        }
                        pos = node.position();
                        if (pos.length > 1) {
                            node.position(calc_pos(pos, x), true);
                        } else if (x > node.limit.leftUpper &&
                            x < node.width()-rightBottomLimit) {
                            node.position(x, true);
                            node.trigger('splitter.resize');
                            node.find('.splitter_panel').
                                trigger('splitter.resize');
                            //e.preventDefault();
                        }
                    } else if (node.orientation == 'horizontal') {
                        var pageY = e.pageY;
                        if(e.originalEvent && e.originalEvent.changedTouches){
                          pageY = e.originalEvent.changedTouches[0].pageY;
                        }
                        var y = pageY-offset.top;
                        if (y <= node.limit.leftUpper) {
                            y = node.limit.leftUpper + 1;
                        } else if (y >= node.height() - rightBottomLimit) {
                            y = node.height() - rightBottomLimit - 1;
                        }
                        pos = node.position();
                        if (pos.length > 1) {
                            node.position(calc_pos(pos, y), true);
                        } else if (y > node.limit.leftUpper &&
                            y < node.height()-rightBottomLimit) {
                            node.position(y, true);
                            node.trigger('splitter.resize');
                            node.find('.splitter_panel').
                                trigger('splitter.resize');
                            //e.preventDefault();
                        }
                    }
                    node.settings.onDrag(e);
                }
            });//*/
        }
        splitters[id] = self;
        self.data('splitter', self);
        return self;
    };
});
