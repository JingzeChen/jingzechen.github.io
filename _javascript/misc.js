import { basic, initSidebar, initTopbar } from './modules/layouts';
import { initLocaleDatetime } from './modules/components';
import { initArchiveDirectory } from './modules/archive-directory';

initSidebar();
initTopbar();
initLocaleDatetime();
initArchiveDirectory();
basic();
