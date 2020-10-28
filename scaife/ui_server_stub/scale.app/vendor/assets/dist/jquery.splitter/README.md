# jQuery Splitter

[![npm](https://img.shields.io/badge/npm-0.28.3-blue.svg)](https://www.npmjs.com/package/jquery.splitter)
![bower](https://img.shields.io/badge/bower-0.28.3-yellow.svg)

jQuery Splitter is plugin that split your content with movable splitter between them.


# Example

```javascript
var splitter = $('#foo').height(200).split({
    orientation: 'vertical',
    limit: 10,
    position: '50%', // if there is no percentage it interpret it as pixels
    onDrag: function(event) {
        console.log(splitter.position());
    }
});
```

```html
<div id="foo">
    <div id="leftPane">Foo</div>
    <div id="rightPane">Bar</div>
</div>
```

**Note**: You need to set the height of the container for splitter to work.


You can use this css:

```css
.container {
  height: 100vh !important;
}
```

to force full height.

# Options

* orientation - string 'horizontal' or 'vertical'.
* limit - number or object `{leftUpper: number, rightBottom: number}` that indicate how many pixels where you can't move the splitter to the edge.
* position - number or string with % indicate initial position of the splitter. (from version 0.28.0 you can use array of numbers or percents for multiple panels, array length need to have the same number as there are splitters so `children.length - 1`).
* onDrag - event fired when draging the splitter, the event object is from mousemove
* percent - boolean that indicate if spliter should use % instead of px (for use in print or when calling the window)

# Methods

Instance returned by splitter is jQuery object with additional methods:

* `refresh()`
* `option (name[, value])` - option setter/getter
* `position(number)`|`position([num1, num2, ...])`|`position()` - position setter/getter (if you have 2 panels you can use single number to set the position for more panels you need to use array with `panels - 1` same as number of splitters)
* `isActive` - returns `boolean`
* `destroy()` - remove splitter data

# Demo

<http://jquery.jcubic.pl/splitter.php>

# Patch Contributors

* Robert Tupelo-Schneck
* Taras Strypko
* [Yury Plashenkov](https://github.com/plashenkov)
* [@beskorsova](https://github.com/beskorsova)

# License

Copyright (C) 2010-2019 Jakub T. Jankiewicz &lt;<https://jcubic.pl/me>&gt;

Released under the terms of the [GNU Lesser General Public License](http://www.gnu.org/licenses/lgpl.html)
