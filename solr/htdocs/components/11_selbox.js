// Generated by CoffeeScript 1.12.6

/* Do not edit this .js, edit the .coffee file and recompile */

(function() {
  (function($) {
    var activate, deactivate, into_view, selected, settext;
    $.fn.selbox = function(options, arg1, arg2, arg3) {
      var opts;
      if ($.type(options) === 'string') {
        if (options === 'activate') {
          return this.each(function() {
            return $(this).trigger('selboxactivate', [true, arg1, arg2, arg3]);
          });
        } else if (options === 'deactivate') {
          return this.each(function() {
            return $(this).trigger('selboxactivate', [false]);
          });
        } else if (options === 'maintext') {
          return this.each(function() {
            return $(this).trigger('selboxtext', [arg1]);
          });
        } else if (options === 'select') {
          return this.each(function() {
            return $(this).trigger('selboxselect', [arg1]);
          });
        }
      } else {
        opts = $.extend({}, $.fn.selbox.defaults, options);
        return this.each(function() {
          $(this).on('selboxtext', function(e, text) {
            return settext($(this), text, opts);
          });
          $(this).on('selboxselect', function(e, id) {
            var ul;
            ul = $(this).data('selboxul');
            if (ul.length) {
              return selected($(this), $("a[href=\"#" + id + "\"]", ul), opts);
            }
          });
          return $(this).on('selboxactivate', function(e, act, maintext, texts, ids) {
            if (act) {
              return activate($(this), maintext, texts, ids, opts);
            } else {
              return deactivate($(this), opts);
            }
          });
        });
      }
    };
    settext = function(el, text, opts) {
      var box;
      box = el.closest('.selboxouter').find('.selboxtext');
      box.html(text);
      return opts.selchange.call(box);
    };
    activate = function(el, maintext, texts, ids, opts) {
      var bord, boxpos, d, extrapad, i, j, k, l, len, len1, len2, li, newbox, outer, p, padbord, ref, ref1, selbox, t, ul, ulover, w;
      if (el.closest('.selboxouter').length) {
        return;
      }
      w = el.width();
      outer = $(opts.template);
      selbox = $('.selbox', outer);
      newbox = $('.selboxnew', outer);
      outer.insertBefore(el);
      newbox.append(el);
      bord = el.outerWidth() - el.innerWidth();
      padbord = el.outerWidth() - el.width();
      el.width(w - selbox.width());
      newbox.width(w + padbord);
      selbox.height(el.height() + el.outerHeight() - el.height());
      $('.selboxtext', selbox).height(selbox.height());
      if (opts.field != null) {
        $('<input/>').attr({
          type: 'hidden',
          name: opts.field
        }).addClass('selboxfield').appendTo(selbox);
      }
      ref = ['left', 'right', 'top', 'bottom'];
      for (j = 0, len = ref.length; j < len; j++) {
        d = ref[j];
        newbox.css("margin-" + d, el.css("margin-" + d));
        el.css("margin-" + d, '0');
      }
      ref1 = ['background-color'];
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        p = ref1[k];
        newbox.css(p, el.css(p));
      }
      el.selbox('maintext', maintext);
      ul = $('ul', outer).css({
        display: 'none',
        width: selbox.width()
      });
      boxpos = newbox.offset();
      ul.appendTo('body').css({
        top: boxpos.top + newbox.height() + "px",
        left: boxpos.left + "px"
      });
      el.data("selboxul", ul);
      selbox.click(function(e) {
        ul.toggle();
        $(document).trigger('ga',['SearchInputFacetDropdown', 'SearchPageResults', ul.css('display') == 'block' ? 'show' : 'hide'])
        return $('.selboxselected', ul).removeClass('selboxselected');
      });
      ulover = ul.outerWidth() - ul.width();
      ul.width(ul.width() - ulover);
      extrapad = (newbox.outerWidth() - newbox.width()) - (ul.outerWidth() - ul.width());
      for (i = l = 0, len2 = texts.length; l < len2; i = ++l) {
        t = texts[i];
        li = $('<a/>').attr('href', '#' + ids[i]).html(t).wrap('<li/>').parent();
        li.css('padding-left', parseInt(li.css('padding-left')) + extrapad + "px").appendTo(ul);
        li.on('click', function(e) {
          return selected(el, $('a', this), opts);
        });
        $('a', li).on('click', function(e) {
          return selected(el, $(this), opts);
        });
        li.mouseleave(function() {
          return $(this).removeClass('selboxselected');
        });
        li.mouseenter(function() {
          var lel;
          ul = $(this).closest('ul');
          ul.find('li').removeClass('selboxselected');
          lel = ul.find('.selboxforce').removeClass('selboxforce');
          if (!lel.length) {
            lel = $(this);
          }
          return lel.addClass('selboxselected');
        });
      }
      $('html').on('focusin', function(e) {
        var tg;
        tg = $(e.target);
        if (tg.parents('.selboxlist').length) {
          return true;
        }
        el.data("selboxul").hide();
        return true;
      });
      return $('html').keydown(function(e) {
        var sel, sela;
        switch (e.keyCode) {
          case 27:
            return ul.hide();
          case 40:
            sel = $('.selboxselected', ul).removeClass('selboxselected').next();
            if (!sel.length) {
              sel = $('li', ul).first();
            }
            sel.addClass('selboxselected');
            return into_view(sel);
          case 38:
            sel = $('.selboxselected', ul).removeClass('selboxselected').prev();
            if (!sel.length) {
              sel = $('li', ul).last();
            }
            sel.addClass('selboxselected');
            return into_view(sel);
          case 13:
            sela = $('.selboxselected a', outer);
            if (sela.length) {
              selected(el, sela, opts);
            }
            return ul.hide();
        }
      });
    };
    selected = function(el, a, opts) {
      var href;
      href = a.attr('href');
      href = href.substring(href.indexOf('#'));
      opts.action.call(el, href.substring(1), a.html(), opts);
      a.closest('ul').hide();
      $('.selboxfield', el.closest('.selboxnew')).val(href.substring(1));
      return false;
    };
    into_view = function(el) {
      var el_bot, el_top, sc_height, ul;
      el_top = el.position().top;
      el_bot = el_top + el.outerHeight();
      ul = el.closest('ul');
      sc_height = ul.height();
      ul.find('.selboxforce').removeClass('selboxforce');
      el.addClass('selboxforce');
      if (el_top < 0) {
        return ul.scrollTop(ul.scrollTop() + el_top - 10);
      } else if (el_bot > sc_height) {
        return ul.scrollTop(ul.scrollTop() + (el_bot - sc_height) + 10);
      } else {

      }
    };
    deactivate = function(el, opts) {
      var outer;
      outer = el.closest('.selboxouter');
      if (!outer.length) {
        return;
      }
      el.width(outer.width() - (el.outerWidth() - el.width()));
      el.insertAfter(outer);
      el.data("selboxul").hide();
      return outer.remove();
    };
    return $.fn.selbox.defaults = {
      action: function() {},
      selchange: function() {},
      field: null,
      template: "<div class=\"selboxouter\">\n  <div class=\"selboxnew\">\n    <div class=\"selbox\">\n      <div class=\"selboxarrow\">\n        <div class=\"selboxtext\">\n          Hello\n        </div>\n      </div>\n    </div>\n  </div>\n  <ul class=\"selboxlist\">\n  </ul>\n</div>"
    };
  })(jQuery);

}).call(this);
