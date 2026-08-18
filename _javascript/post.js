import { basic, initTopbar, initSidebar } from './modules/layouts';

import {
  loadImg,
  imgPopup,
  initLocaleDatetime,
  initClipboard,
  initToc,
  loadMermaid
} from './modules/components';
import { initPodcastEpisode } from './modules/podcast';
import { initCourseWorkbench } from './modules/course';

loadImg();
initToc();
imgPopup();
initSidebar();
initLocaleDatetime();
initClipboard();
initTopbar();
loadMermaid();
initPodcastEpisode();
initCourseWorkbench();
basic();
