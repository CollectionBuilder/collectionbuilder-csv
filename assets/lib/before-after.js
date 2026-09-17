/**
 * TAMU Before and After - Before and After Image Comparison Slider
 * A lightweight vanilla JavaScript Web Component for comparing two images from different time periods.
 *
 * Usage:
 * <before-after
 *      before="image1.jpg"
 *      after="image2.jpg"
 *      before-label="Before"
 *      after-label="After"
 *      start-position="50">
 * </before-after>
 *
 */

(function() {
  'use strict';

  const CSS = `
    :host {
      display: block;
      position: relative;
      width: 100%;
      height: 100%;
      min-height: 400px;
    }

    .before-after-container {
      position: relative;
      width: 100%;
      height: 100%;
      overflow: hidden;
      cursor: ew-resize;
      user-select: none;
      touch-action: none;
      background-color: #f0f0f0;
    }

    .before-after-container.vertical {
      cursor: ns-resize;
    }

    .before-after-image-container {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      display: flex;
      flex-direction: column;
    }

    .before-after-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
      pointer-events: none;
      opacity: 0;
      transition: opacity 0.3s ease;
    }

    .before-after-image.loaded {
      opacity: 1;
    }

    .before-after-before-container {
      z-index: 2;
    }

    .before-after-slider {
      position: absolute;
      top: 0;
      bottom: 0;
      width: 4px;
      transform: translateX(-50%);
      z-index: 10;
      cursor: ew-resize;
    }

    .before-after-slider.vertical {
      left: 0;
      right: 0;
      top: auto;
      bottom: auto;
      width: auto;
      height: 4px;
      transform: translateY(-50%);
      cursor: ns-resize;
    }

    .before-after-slider-line {
      position: absolute;
      top: 0;
      bottom: 0;
      left: 50%;
      width: 2px;
      background-color: white;
      transform: translateX(-50%);
      box-shadow: 0 0 8px rgba(0, 0, 0, 0.5);
    }

    .before-after-slider.vertical .before-after-slider-line {
      left: 0;
      right: 0;
      top: 50%;
      bottom: auto;
      width: auto;
      height: 2px;
      transform: translateY(-50%);
    }

    .before-after-slider-button {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 48px;
      height: 48px;
      border-radius: 50%;
      border: 2px solid white;
      background-color: rgba(0, 0, 0, 0.8);
      color: white;
      cursor: ew-resize;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 0 12px rgba(0, 0, 0, 0.5);
      transition: all 0.2s ease;
      padding: 0;
      outline: none;
    }

    .before-after-slider.vertical .before-after-slider-button {
      cursor: ns-resize;
    }

    .before-after-slider-button:hover {
      background-color: rgba(0, 0, 0, 0.95);
      transform: translate(-50%, -50%) scale(1.1);
    }

    .before-after-slider-button:active {
      transform: translate(-50%, -50%) scale(0.95);
    }

    .before-after-slider-button svg {
      width: 24px;
      height: 24px;
    }

    .before-after-label {
      position: absolute;
      top: 1rem;
      padding: 0.5rem 1rem;
      background-color: rgba(0, 0, 0, 0.75);
      color: white;
      font-size: 0.875rem;
      font-weight: 600;
      border-radius: 4px;
      pointer-events: none;
      z-index: 2;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      transition: opacity 0.2s ease;
    }

    .before-after-label.before {
      left: 1rem;
    }

    .before-after-label.after {
      right: 1rem;
    }

    .vertical .before-after-label.before {
      left: auto;
      right: auto;
      top: 1rem;
    }

    .vertical .before-after-label.after {
      left: auto;
      right: auto;
      top: auto;
      bottom: 1rem;
    }

    .before-after-link {
      position: absolute;
      bottom: 10px;
      left: 10px;
      z-index: 20;
      background-color: rgba(0, 0, 0, 0.75);
      color: white;
      padding: 0.5rem 0.75rem;
      border-radius: 4px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-size: 0.875rem;
      text-decoration: none;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      transition: background-color 0.2s ease;
    }

    .before-after-link:hover {
      background-color: rgba(0, 0, 0, 0.9);
    }

    .before-after-link img {
      width: 16px;
      height: 16px;
      display: block;
    }
  `;

  class BeforeAfter extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: 'open' });

      this.sliderPosition = 50;
      this.isDragging = false;
      this.imagesLoaded = { before: false, after: false };
    }

    static get observedAttributes() {
      return ['before', 'after', 'before-label', 'after-label', 'start-position', 'show-labels', 'orientation', 'link-url', 'link-text', 'favicon-url'];
    }

    connectedCallback() {
      this.render();
      this.attachEvents();
    }

    disconnectedCallback() {
      this.cleanup();
    }

    attributeChangedCallback(name, oldValue, newValue) {
      if (oldValue !== newValue && this.shadowRoot.querySelector('.before-after-container')) {
        this.render();
      }
    }

    get beforeImage() {
      return this.getAttribute('before') || '';
    }

    get afterImage() {
      return this.getAttribute('after') || '';
    }

    get beforeLabel() {
      return this.getAttribute('before-label') || 'Before';
    }

    get afterLabel() {
      return this.getAttribute('after-label') || 'After';
    }

    get startPosition() {
      return parseFloat(this.getAttribute('start-position') || '50');
    }

    get showLabels() {
      return this.getAttribute('show-labels') !== 'false';
    }

    get orientation() {
      const value = this.getAttribute('orientation') || 'horizontal';
      return value === 'vertical' ? 'vertical' : 'horizontal';
    }

    get isVertical() {
      return this.orientation === 'vertical';
    }

    get linkUrl() {
      return this.getAttribute('link-url') || '';
    }

    get linkText() {
      return this.getAttribute('link-text') || '';
    }

    get faviconUrl() {
      return this.getAttribute('favicon-url') || '';
    }

    render() {
      const style = document.createElement('style');
      style.textContent = CSS;

      this.container = document.createElement('div');
      this.container.className = this.isVertical ? 'before-after-container vertical' : 'before-after-container';
      this.container.setAttribute('role', 'group');
      this.container.setAttribute('aria-label', `Image comparison: ${this.beforeLabel} and ${this.afterLabel}`);

      this.afterContainer = this.createImageContainer('after');
      this.container.appendChild(this.afterContainer);

      this.beforeContainer = this.createImageContainer('before');
      this.beforeContainer.classList.add('before-after-before-container');
      this.container.appendChild(this.beforeContainer);

      this.slider = this.createSlider();
      this.container.appendChild(this.slider);

      if (this.linkUrl && this.linkText) {
        const link = document.createElement('a');
        link.href = this.linkUrl;
        link.className = 'before-after-link';
        link.target = '_blank';
        link.rel = 'noopener noreferrer';

        if (this.faviconUrl) {
          const favicon = document.createElement('img');
          favicon.src = this.faviconUrl;
          favicon.alt = '';
          link.appendChild(favicon);
        }

        const linkText = document.createElement('span');
        linkText.textContent = this.linkText;
        link.appendChild(linkText);

        this.container.appendChild(link);
      }

      this.shadowRoot.innerHTML = '';
      this.shadowRoot.appendChild(style);
      this.shadowRoot.appendChild(this.container);

      this.sliderPosition = this.startPosition;
      this.updateSliderPosition(this.sliderPosition);
    }

    createImageContainer(type) {
      const container = document.createElement('div');
      container.className = 'before-after-image-container';

      const img = document.createElement('img');
      img.className = 'before-after-image';
      img.src = type === 'before' ? this.beforeImage : this.afterImage;
      img.alt = type === 'before' ? this.beforeLabel : this.afterLabel;

      img.addEventListener('load', () => {
        img.classList.add('loaded');
        this.imagesLoaded[type] = true;
      });

      container.appendChild(img);

      if (this.showLabels) {
        const label = document.createElement('div');
        label.className = `before-after-label ${type}`;
        label.textContent = type === 'before' ? this.beforeLabel : this.afterLabel;

        // Store reference to label for visibility control
        if (type === 'before') {
          this.beforeLabelEl = label;
        } else {
          this.afterLabelEl = label;
        }

        container.appendChild(label);
      }

      return container;
    }

    createSlider() {
      const slider = document.createElement('div');
      slider.className = this.isVertical ? 'before-after-slider vertical' : 'before-after-slider';
      slider.setAttribute('role', 'slider');
      slider.setAttribute('aria-label', 'Image comparison slider');
      slider.setAttribute('aria-valuemin', '0');
      slider.setAttribute('aria-valuemax', '100');
      slider.setAttribute('aria-valuenow', this.sliderPosition.toString());
      slider.setAttribute('aria-valuetext', `${Math.round(this.sliderPosition)}% revealed`);
      slider.setAttribute('tabindex', '0');

      const line = document.createElement('div');
      line.className = 'before-after-slider-line';
      slider.appendChild(line);

      const button = document.createElement('button');
      button.className = 'before-after-slider-button';
      button.setAttribute('aria-label', 'Drag to compare images');
      button.setAttribute('tabindex', '-1');

      // Different icon based on orientation
      const icon = this.isVertical ? `
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden="true">
          <path d="M18 15l-6-6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          <path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        </svg>
      ` : `
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden="true">
          <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          <path d="M9 6l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
        </svg>
      `;

      button.innerHTML = icon;
      slider.appendChild(button);

      return slider;
    }

    attachEvents() {
      this.boundMouseMove = this.handleMouseMove.bind(this);
      this.boundMouseUp = this.handleMouseUp.bind(this);
      this.boundTouchMove = this.handleTouchMove.bind(this);
      this.boundTouchEnd = this.handleTouchEnd.bind(this);
      this.boundKeyDown = this.handleKeyDown.bind(this);

      this.slider.addEventListener('mousedown', this.handleMouseDown.bind(this));
      this.slider.addEventListener('touchstart', this.handleTouchStart.bind(this));
      this.slider.addEventListener('keydown', this.boundKeyDown);
    }

    handleMouseDown(e) {
      e.preventDefault();
      this.isDragging = true;
      const coord = this.isVertical ? e.clientY : e.clientX;
      this.updatePosition(coord);

      document.addEventListener('mousemove', this.boundMouseMove);
      document.addEventListener('mouseup', this.boundMouseUp);
    }

    handleMouseMove(e) {
      if (!this.isDragging) return;
      const coord = this.isVertical ? e.clientY : e.clientX;
      this.updatePosition(coord);
    }

    handleMouseUp() {
      this.isDragging = false;
      document.removeEventListener('mousemove', this.boundMouseMove);
      document.removeEventListener('mouseup', this.boundMouseUp);
    }

    handleTouchStart(e) {
      this.isDragging = true;
      const coord = this.isVertical ? e.touches[0].clientY : e.touches[0].clientX;
      this.updatePosition(coord);

      document.addEventListener('touchmove', this.boundTouchMove, { passive: false });
      document.addEventListener('touchend', this.boundTouchEnd);
    }

    handleTouchMove(e) {
      if (!this.isDragging) return;
      e.preventDefault();
      const coord = this.isVertical ? e.touches[0].clientY : e.touches[0].clientX;
      this.updatePosition(coord);
    }

    handleTouchEnd() {
      this.isDragging = false;
      document.removeEventListener('touchmove', this.boundTouchMove);
      document.removeEventListener('touchend', this.boundTouchEnd);
    }

    handleKeyDown(e) {
      let newPosition = this.sliderPosition;
      const step = e.shiftKey ? 10 : 1; // Bigger steps with Shift key

      if (this.isVertical) {
        switch(e.key) {
          case 'ArrowUp':
          case 'Up':
            e.preventDefault();
            newPosition = Math.max(0, this.sliderPosition - step);
            break;
          case 'ArrowDown':
          case 'Down':
            e.preventDefault();
            newPosition = Math.min(100, this.sliderPosition + step);
            break;
          case 'Home':
            e.preventDefault();
            newPosition = 0;
            break;
          case 'End':
            e.preventDefault();
            newPosition = 100;
            break;
          default:
            return;
        }
      } else {
        switch(e.key) {
          case 'ArrowLeft':
          case 'Left':
            e.preventDefault();
            newPosition = Math.max(0, this.sliderPosition - step);
            break;
          case 'ArrowRight':
          case 'Right':
            e.preventDefault();
            newPosition = Math.min(100, this.sliderPosition + step);
            break;
          case 'Home':
            e.preventDefault();
            newPosition = 0;
            break;
          case 'End':
            e.preventDefault();
            newPosition = 100;
            break;
          default:
            return;
        }
      }

      this.updateSliderPosition(newPosition);
    }

    updatePosition(coord) {
      const rect = this.container.getBoundingClientRect();
      let percentage;

      if (this.isVertical) {
        const y = coord - rect.top;
        percentage = Math.max(0, Math.min(100, (y / rect.height) * 100));
      } else {
        const x = coord - rect.left;
        percentage = Math.max(0, Math.min(100, (x / rect.width) * 100));
      }

      this.updateSliderPosition(percentage);
    }

    updateSliderPosition(percentage) {
      this.sliderPosition = percentage;

      if (this.isVertical) {
        this.slider.style.top = `${percentage}%`;
        this.beforeContainer.style.clipPath = `inset(0 0 ${100 - percentage}% 0)`;
      } else {
        this.slider.style.left = `${percentage}%`;
        this.beforeContainer.style.clipPath = `inset(0 ${100 - percentage}% 0 0)`;
      }

      this.slider.setAttribute('aria-valuenow', percentage.toString());
      this.slider.setAttribute('aria-valuetext', `${Math.round(percentage)}% revealed`);

      // Hide labels when they would be mostly clipped
      if (this.beforeLabelEl) {
        this.beforeLabelEl.style.opacity = percentage < 15 ? '0' : '1';
      }
      if (this.afterLabelEl) {
        this.afterLabelEl.style.opacity = percentage > 85 ? '0' : '1';
      }
    }

    cleanup() {
      document.removeEventListener('mousemove', this.boundMouseMove);
      document.removeEventListener('mouseup', this.boundMouseUp);
      document.removeEventListener('touchmove', this.boundTouchMove);
      document.removeEventListener('touchend', this.boundTouchEnd);
    }
  }

  // Register new web component
  if (!customElements.get('before-after')) {
    customElements.define('before-after', BeforeAfter);
  }

  // Expose the class for Programmatic Use
  window.BeforeAfter = BeforeAfter;

  /**
   * Opacity Compare - Stacked Image Comparison with Opacity Slider
   * A web component that stacks two images and lets you drag a slider to
   * blend between them by adjusting the top image's opacity.
   *
   * Usage:
   * <opacity-compare
   *      before="image1.jpg"
   *      after="image2.jpg"
   *      before-label="Before"
   *      after-label="After"
   *      start-opacity="50">
   * </opacity-compare>
   */

  const OPACITY_CSS = `
    :host {
      display: block;
      position: relative;
      width: 100%;
      height: 100%;
      min-height: 400px;
    }

    .oc-container {
      position: relative;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: #f0f0f0;
      user-select: none;
      touch-action: none;
    }

    .oc-image {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      object-fit: contain;
      pointer-events: none;
      transition: opacity 0s;
    }

    .oc-bottom {
      z-index: 1;
    }

    .oc-top {
      z-index: 2;
    }

    .oc-label {
      position: absolute;
      top: 1rem;
      padding: 0.5rem 1rem;
      background-color: rgba(0, 0, 0, 0.75);
      color: white;
      font-size: 0.875rem;
      font-weight: 600;
      border-radius: 4px;
      pointer-events: none;
      z-index: 10;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      transition: opacity 0.2s ease;
    }

    .oc-label-before {
      left: 1rem;
    }

    .oc-label-after {
      right: 1rem;
    }

    .oc-slider-wrap {
      position: absolute;
      bottom: 1.25rem;
      left: 1.5rem;
      right: 1.5rem;
      z-index: 20;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .oc-slider-track {
      flex: 1;
      height: 6px;
      background: rgba(255, 255, 255, 0.35);
      border-radius: 3px;
      position: relative;
      cursor: pointer;
      box-shadow: 0 1px 4px rgba(0, 0, 0, 0.4);
      backdrop-filter: blur(4px);
    }

    .oc-slider-fill {
      height: 100%;
      border-radius: 3px;
      background: white;
      pointer-events: none;
    }

    .oc-slider-thumb {
      position: absolute;
      top: 50%;
      width: 22px;
      height: 22px;
      border-radius: 50%;
      background: white;
      border: 2px solid rgba(0, 0, 0, 0.25);
      transform: translate(-50%, -50%);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.45);
      cursor: grab;
      transition: transform 0.1s ease, box-shadow 0.1s ease;
    }

    .oc-slider-thumb.dragging {
      cursor: grabbing;
      transform: translate(-50%, -50%) scale(1.2);
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.55);
    }

    .oc-slider-track:focus {
      outline: 2px solid white;
      outline-offset: 3px;
    }

    .oc-icon {
      width: 20px;
      height: 20px;
      flex-shrink: 0;
      color: white;
      filter: drop-shadow(0 1px 2px rgba(0,0,0,0.5));
    }
  `;

  class OpacityCompare extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: 'open' });
      this.opacity = 50;
      this.isDragging = false;
    }

    static get observedAttributes() {
      return ['before', 'after', 'before-label', 'after-label', 'start-opacity', 'auto-play', 'auto-play-speed', 'auto-play-stop-on-interact'];
    }

    connectedCallback() {
      this.render();
      this.attachEvents();
      if (this.autoPlay) this.startAutoPlay();
    }

    disconnectedCallback() {
      this.cleanup();
    }

    attributeChangedCallback(name, oldValue, newValue) {
      if (oldValue !== newValue && this.shadowRoot.querySelector('.oc-container')) {
        this.stopAutoPlay();
        this.render();
        this.attachEvents();
        if (this.autoPlay) this.startAutoPlay();
      }
    }

    get beforeImage() { return this.getAttribute('before') || ''; }
    get afterImage()  { return this.getAttribute('after')  || ''; }
    get beforeLabel() { return this.getAttribute('before-label') || 'Before'; }
    get afterLabel()  { return this.getAttribute('after-label')  || 'After'; }
    get startOpacity() { return parseFloat(this.getAttribute('start-opacity') || '50'); }
    get autoPlay() { return this.hasAttribute('auto-play'); }
    get autoPlaySpeed() { return parseFloat(this.getAttribute('auto-play-speed') || '3000'); }
    get autoPlayStopOnInteract() { return this.getAttribute('auto-play-stop-on-interact') !== 'false'; }

    render() {
      const style = document.createElement('style');
      style.textContent = OPACITY_CSS;

      const container = document.createElement('div');
      container.className = 'oc-container';
      container.setAttribute('role', 'group');
      container.setAttribute('aria-label', `Opacity image comparison: ${this.beforeLabel} and ${this.afterLabel}`);

      // Bottom image (always fully visible)
      const bottomImg = document.createElement('img');
      bottomImg.className = 'oc-image oc-bottom';
      bottomImg.src = this.beforeImage;
      bottomImg.alt = this.beforeLabel;

      // Top image (opacity controlled by slider)
      const topImg = document.createElement('img');
      topImg.className = 'oc-image oc-top';
      topImg.src = this.afterImage;
      topImg.alt = this.afterLabel;

      // Labels
      const beforeLabelEl = document.createElement('div');
      beforeLabelEl.className = 'oc-label oc-label-before';
      beforeLabelEl.textContent = this.beforeLabel;

      const afterLabelEl = document.createElement('div');
      afterLabelEl.className = 'oc-label oc-label-after';
      afterLabelEl.textContent = this.afterLabel;

      // Slider wrapper (holds eye icons + track)
      const sliderWrap = document.createElement('div');
      sliderWrap.className = 'oc-slider-wrap';

      const iconBefore = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      iconBefore.setAttribute('viewBox', '0 0 24 24');
      iconBefore.setAttribute('fill', 'none');
      iconBefore.setAttribute('aria-hidden', 'true');
      iconBefore.classList.add('oc-icon');
      iconBefore.innerHTML = `<circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="2"/><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7-10-7-10-7z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>`;

      const track = document.createElement('div');
      track.className = 'oc-slider-track';
      track.setAttribute('role', 'slider');
      track.setAttribute('aria-label', 'Opacity slider');
      track.setAttribute('aria-valuemin', '0');
      track.setAttribute('aria-valuemax', '100');
      track.setAttribute('tabindex', '0');

      const fill = document.createElement('div');
      fill.className = 'oc-slider-fill';

      const thumb = document.createElement('div');
      thumb.className = 'oc-slider-thumb';

      track.appendChild(fill);
      track.appendChild(thumb);

      const iconAfter = iconBefore.cloneNode(true);

      sliderWrap.appendChild(iconBefore);
      sliderWrap.appendChild(track);
      sliderWrap.appendChild(iconAfter);

      container.appendChild(bottomImg);
      container.appendChild(topImg);
      container.appendChild(beforeLabelEl);
      container.appendChild(afterLabelEl);
      container.appendChild(sliderWrap);

      this.shadowRoot.innerHTML = '';
      this.shadowRoot.appendChild(style);
      this.shadowRoot.appendChild(container);

      this.container  = container;
      this.topImg     = topImg;
      this.track      = track;
      this.fill       = fill;
      this.thumb      = thumb;
      this.beforeLabelEl = beforeLabelEl;
      this.afterLabelEl  = afterLabelEl;

      this.opacity = this.startOpacity;
      this.updateOpacity(this.opacity);
    }

    updateOpacity(value) {
      this.opacity = Math.max(0, Math.min(100, value));
      this.topImg.style.opacity   = this.opacity / 100;
      this.fill.style.width       = `${this.opacity}%`;
      this.thumb.style.left       = `${this.opacity}%`;
      this.track.setAttribute('aria-valuenow',  this.opacity.toString());
      this.track.setAttribute('aria-valuetext', `${Math.round(this.opacity)}% opacity`);

      // Fade out each label when its image is barely visible
      this.afterLabelEl.style.opacity  = this.opacity < 15  ? '0' : '1';
      this.beforeLabelEl.style.opacity = this.opacity > 85  ? '0' : '1';
    }

    startAutoPlay() {
      if (this._rafId) return;
      this._autoPlayDir = 1;
      this._autoPlayLastTime = null;

      const tick = (timestamp) => {
        if (this._autoPlayLastTime === null) {
          this._autoPlayLastTime = timestamp;
        }
        const elapsed = timestamp - this._autoPlayLastTime;
        this._autoPlayLastTime = timestamp;

        const delta = (elapsed / this.autoPlaySpeed) * 100 * this._autoPlayDir;
        let next = this.opacity + delta;

        if (next >= 100) { next = 100; this._autoPlayDir = -1; }
        else if (next <= 0) { next = 0; this._autoPlayDir = 1; }

        this.updateOpacity(next);
        this._rafId = requestAnimationFrame(tick);
      };

      this._rafId = requestAnimationFrame(tick);
    }

    stopAutoPlay() {
      if (this._rafId) {
        cancelAnimationFrame(this._rafId);
        this._rafId = null;
      }
    }

    opacityFromClientX(clientX) {
      const rect = this.track.getBoundingClientRect();
      return Math.max(0, Math.min(100, ((clientX - rect.left) / rect.width) * 100));
    }

    attachEvents() {
      this.boundMouseMove  = this.handleMouseMove.bind(this);
      this.boundMouseUp    = this.handleMouseUp.bind(this);
      this.boundTouchMove  = this.handleTouchMove.bind(this);
      this.boundTouchEnd   = this.handleTouchEnd.bind(this);

      this.track.addEventListener('mousedown',  this.handleMouseDown.bind(this));
      this.track.addEventListener('touchstart', this.handleTouchStart.bind(this));
      this.track.addEventListener('keydown',    this.handleKeyDown.bind(this));
    }

    handleMouseDown(e) {
      e.preventDefault();
      if (this.autoPlayStopOnInteract) this.stopAutoPlay();
      this.isDragging = true;
      this.thumb.classList.add('dragging');
      this.updateOpacity(this.opacityFromClientX(e.clientX));
      document.addEventListener('mousemove', this.boundMouseMove);
      document.addEventListener('mouseup',   this.boundMouseUp);
    }

    handleMouseMove(e) {
      if (!this.isDragging) return;
      this.updateOpacity(this.opacityFromClientX(e.clientX));
    }

    handleMouseUp() {
      this.isDragging = false;
      this.thumb.classList.remove('dragging');
      document.removeEventListener('mousemove', this.boundMouseMove);
      document.removeEventListener('mouseup',   this.boundMouseUp);
    }

    handleTouchStart(e) {
      if (this.autoPlayStopOnInteract) this.stopAutoPlay();
      this.isDragging = true;
      this.thumb.classList.add('dragging');
      this.updateOpacity(this.opacityFromClientX(e.touches[0].clientX));
      document.addEventListener('touchmove', this.boundTouchMove, { passive: false });
      document.addEventListener('touchend',  this.boundTouchEnd);
    }

    handleTouchMove(e) {
      if (!this.isDragging) return;
      e.preventDefault();
      this.updateOpacity(this.opacityFromClientX(e.touches[0].clientX));
    }

    handleTouchEnd() {
      this.isDragging = false;
      this.thumb.classList.remove('dragging');
      document.removeEventListener('touchmove', this.boundTouchMove);
      document.removeEventListener('touchend',  this.boundTouchEnd);
    }

    handleKeyDown(e) {
      const step = e.shiftKey ? 10 : 1;
      switch (e.key) {
        case 'ArrowLeft':
        case 'Left':
          e.preventDefault();
          this.updateOpacity(this.opacity - step);
          break;
        case 'ArrowRight':
        case 'Right':
          e.preventDefault();
          this.updateOpacity(this.opacity + step);
          break;
        case 'Home':
          e.preventDefault();
          this.updateOpacity(0);
          break;
        case 'End':
          e.preventDefault();
          this.updateOpacity(100);
          break;
        default:
          return;
      }
    }

    cleanup() {
      this.stopAutoPlay();
      document.removeEventListener('mousemove', this.boundMouseMove);
      document.removeEventListener('mouseup',   this.boundMouseUp);
      document.removeEventListener('touchmove', this.boundTouchMove);
      document.removeEventListener('touchend',  this.boundTouchEnd);
    }
  }

  if (!customElements.get('opacity-compare')) {
    customElements.define('opacity-compare', OpacityCompare);
  }

  window.OpacityCompare = OpacityCompare;

})();
