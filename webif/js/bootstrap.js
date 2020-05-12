define([
  'dojo/query',
  'dojo/on',
  'dojo/_base/window',
  'dojo/_base/lang',
  'dojo/dom-class',
  'dojo/dom-construct',
  'dojo/dom-geometry'
], 
function (
  query, on, win, lang, domClass, domConstruct, domGeometry
) {
  return {
    showPopover: function (template, refNode, pos) {
      var target, refGeo, targetGeo, newGeo, backdrop;

      query('.popover, .popover-backdrop').forEach(domConstruct.destroy);

      target = domConstruct.create('div', {
        className: 'popover fade ' + pos
      }, win.body(), 'last');
      domConstruct.create('div', {
        className: 'arrow'
      }, target, 'last');
      domConstruct.create('div', {
        className: 'popover-inside',
        innerHTML: template
      }, target, 'last');

      backdrop = domConstruct.create('div', {
        className: 'popover-backdrop fade'
      }, win.body(), 'last');

      on(backdrop, 'click', this.clearPopover);
      on(query('.btn', target), 'click', this.clearPopover);

      refGeo = domGeometry.position(refNode, true);
      targetGeo = domGeometry.getMarginBox(target);

      switch(pos) {
        case 'top': 
          newGeo = {
            t: refGeo.y - targetGeo.h - 20,
            l: refGeo.x - targetGeo.w / 2 + refGeo.w / 2
          };
          break;
        case 'bottom': 
          newGeo = {
            t: refGeo.y + refGeo.h,
            l: refGeo.x - targetGeo.w / 2 + refGeo.w / 2
          };
          break;
        case 'left': 
          newGeo = {
            t: refGeo.y - targetGeo.h / 2 + refGeo.h / 2,
            l: refGeo.x - targetGeo.w
          };
          break;
        case 'right': 
          newGeo = {
            t: refGeo.y - targetGeo.h / 2 + refGeo.h / 2,
            l: refGeo.x + refGeo.w
          };
          break;
        default: throw 'Invalid popover position';
      } 

      domGeometry.setMarginBox(target, newGeo);

      domClass.add(target, 'in');
      domClass.add(backdrop, 'in');

      target.focus();

      return target;
    },

    clearPopover: function () {
      query('div.popover-backdrop').forEach(domConstruct.destroy);
      query('div.popover').removeClass('in');
      setTimeout(function () {
        query('div.popover:not(.in)').forEach(domConstruct.destroy);
      }, 500);
    },

    showAlert: function (className, template) {
      var node, clear;

      node = domConstruct.create('div', {
        className: 'fade alert ' + className,
        innerHTML: template
      }, query('.js-alert-container')[0], 'first');

      domClass.add(node, 'in');

      clear = lang.partial(this.clearAlert, node);
      on(node, 'click', clear);
      setTimeout(clear, 5000);
      return node;
    },

    clearAlert: function (element) {
      domClass.remove(element, 'in');
      setTimeout(lang.partial(domConstruct.destroy, element), 500);
    },

    clearAllAlerts: function () {
      query('.js-alert-container *').forEach(domConstruct.destroy);
    }

  };
});

