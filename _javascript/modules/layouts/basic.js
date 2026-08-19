import { back2top, loadTooltip, modeWatcher } from '../components';
import { initAnalytics } from '../analytics';

export function basic() {
  modeWatcher();
  back2top();
  loadTooltip();
  initAnalytics();
}
