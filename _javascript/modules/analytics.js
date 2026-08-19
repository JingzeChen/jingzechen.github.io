const ANALYTICS_EVENT_ATTRIBUTE = 'data-analytics-event';
const ANALYTICS_VALUE_ATTRIBUTE = 'data-analytics-value';
const ANALYTICS_TRIGGER_ATTRIBUTE = 'data-analytics-trigger';
const ANALYTICS_VALUE_SOURCE_ATTRIBUTE = 'data-analytics-value-source';

function normalizeEventPart(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80);
}

export function trackEvent(name, value) {
  if (typeof window.goatcounter?.count !== 'function') {
    return;
  }

  const path = [name, value]
    .map(normalizeEventPart)
    .filter(Boolean)
    .join(':');

  if (path === '') {
    return;
  }

  window.goatcounter.count({ path, event: true, no_session: true });
}

function declaredValue(target) {
  const prefix = target.getAttribute(ANALYTICS_VALUE_ATTRIBUTE);
  const source = target.getAttribute(ANALYTICS_VALUE_SOURCE_ATTRIBUTE);
  let value = '';

  if (source === 'value' && 'value' in target) {
    value = target.value || 'all';
  } else if (source === 'aria-pressed') {
    value = target.getAttribute('aria-pressed');
  }

  return [prefix, value].filter(Boolean).join('-');
}

function trackDeclaredEvent(event) {
  if (!(event.target instanceof Element)) {
    return;
  }

  const target = event.target.closest(`[${ANALYTICS_EVENT_ATTRIBUTE}]`);

  if (target === null) {
    return;
  }

  const trigger = target.getAttribute(ANALYTICS_TRIGGER_ATTRIBUTE) ?? 'click';

  if (trigger !== event.type) {
    return;
  }

  trackEvent(target.getAttribute(ANALYTICS_EVENT_ATTRIBUTE), declaredValue(target));
}

function trackTocClick(event) {
  if (!(event.target instanceof Element)) {
    return;
  }

  const link = event.target.closest('.toc-link');
  const headingId = link?.hash?.slice(1);
  let heading;

  try {
    heading = headingId ? document.getElementById(decodeURIComponent(headingId)) : null;
  } catch {
    return;
  }

  if (heading?.tagName.match(/^H[2-4]$/)) {
    trackEvent('toc_click', heading.tagName.toLowerCase());
  }
}

export function initAnalytics() {
  document.addEventListener('click', trackDeclaredEvent);
  document.addEventListener('click', trackTocClick);
  document.addEventListener('change', trackDeclaredEvent);
}