const TRANSCRIPT_GROUP_SECONDS = 120;

function formatTimestamp(totalSeconds) {
  const seconds = Math.max(0, Math.floor(totalSeconds));
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainder = seconds % 60;

  return [hours, minutes, remainder]
    .map((value) => String(value).padStart(2, '0'))
    .join(':');
}

function parseTimestamp(value) {
  const parts = value.trim().split(':').map((part) => Number(part));
  if (parts.length === 0 || parts.length > 3 || parts.some(Number.isNaN)) return null;

  if (parts.length === 3) {
    if (parts[1] >= 60 || parts[2] >= 60) return null;
    return parts[0] * 3600 + parts[1] * 60 + parts[2];
  }

  if (parts.length === 2) {
    if (parts[1] >= 60) return null;
    return parts[0] * 60 + parts[1];
  }

  return parts[0];
}

function parseTranscript(source) {
  const segments = source.split('\n').filter(Boolean).map((line) => JSON.parse(line));
  const groups = [];

  segments.forEach((segment) => {
    const bucket = Math.floor(segment.start / TRANSCRIPT_GROUP_SECONDS);
    let group = groups.at(-1);
    if (!group || group.bucket !== bucket) {
      group = { bucket, start: segment.start, text: [] };
      groups.push(group);
    }
    group.text.push(segment.text.trim());
  });

  return groups;
}

function createSection(group) {
  const section = document.createElement('article');
  const timestamp = document.createElement('time');
  const paragraph = document.createElement('p');
  section.className = 'podcast-transcript-section';
  section.dataset.start = group.start;
  section.dataset.searchText = group.text.join(' ').toLowerCase();
  timestamp.dateTime = `PT${Math.floor(group.start)}S`;
  timestamp.textContent = formatTimestamp(group.start);
  paragraph.textContent = group.text.join(' ');
  section.append(timestamp, paragraph);
  return section;
}

export function initPodcastEpisode() {
  const root = document.querySelector('[data-podcast-episode]');
  if (!root) return;

  const dialog = document.querySelector('[data-podcast-transcript-dialog]');
  const content = dialog.querySelector('[data-podcast-transcript-content]');
  const status = dialog.querySelector('[data-podcast-transcript-status]');
  const search = dialog.querySelector('[data-podcast-transcript-search]');
  const time = dialog.querySelector('[data-podcast-transcript-time]');
  let sections = [];
  let loading = null;

  const updateSearch = () => {
    const query = search.value.trim().toLowerCase();
    let visible = 0;
    sections.forEach((section) => {
      const matches = !query || section.dataset.searchText.includes(query);
      section.hidden = !matches;
      if (matches) visible += 1;
    });
    status.textContent = query
      ? `${visible} of ${sections.length} transcript sections`
      : `${sections.length} transcript sections · grouped in two-minute intervals`;
  };

  const loadTranscript = () => {
    if (loading) return loading;
    status.textContent = 'Loading transcript…';
    loading = fetch(root.dataset.transcriptUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`Transcript request failed: ${response.status}`);
        return response.text();
      })
      .then((source) => {
        const fragment = document.createDocumentFragment();
        parseTranscript(source).forEach((group) => fragment.append(createSection(group)));
        content.append(fragment);
        sections = [...content.querySelectorAll('.podcast-transcript-section')];
        updateSearch();
      })
      .catch(() => {
        status.textContent = 'The transcript could not be loaded. Use the plain-text download instead.';
      });
    return loading;
  };

  const jumpTo = (seconds) => {
    if (seconds === null || sections.length === 0) return;
    const target = sections.reduce((candidate, section) => {
      return Number(section.dataset.start) <= seconds ? section : candidate;
    }, sections[0]);
    sections.forEach((section) => section.classList.remove('is-target'));
    target.hidden = false;
    target.classList.add('is-target');
    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    time.value = formatTimestamp(seconds);
  };

  const openTranscript = (seconds = null) => {
    if (!dialog.open) dialog.showModal();
    document.body.classList.add('garden-scroll-lock');
    loadTranscript().then(() => jumpTo(seconds));
  };

  const closeTranscript = () => {
    dialog.close();
    document.body.classList.remove('garden-scroll-lock');
  };

  root.querySelector('[data-podcast-transcript-open]').addEventListener('click', () => openTranscript());

  document.querySelectorAll('#podcast-summary h3').forEach((heading) => {
    const match = heading.textContent.trim().match(/^(\d{2}:\d{2}:\d{2})/);
    if (!match) return;
    const button = document.createElement('button');
    const icon = document.createElement('i');
    const label = document.createElement('span');
    button.type = 'button';
    button.className = 'podcast-chapter-transcript';
    button.dataset.transcriptStart = parseTimestamp(match[1]);
    button.title = `Open transcript at ${match[1]}`;
    button.setAttribute('aria-label', button.title);
    icon.className = 'fas fa-align-left';
    icon.setAttribute('aria-hidden', 'true');
    label.textContent = 'Transcript';
    button.append(icon, label);
    button.addEventListener('click', () => openTranscript(Number(button.dataset.transcriptStart)));
    heading.append(button);
  });

  search.addEventListener('input', updateSearch);
  dialog.querySelector('[data-podcast-transcript-jump]').addEventListener('click', () => {
    const seconds = parseTimestamp(time.value);
    if (seconds === null) {
      status.textContent = 'Enter a timestamp as HH:MM:SS or MM:SS.';
      return;
    }
    jumpTo(seconds);
  });
  time.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') dialog.querySelector('[data-podcast-transcript-jump]').click();
  });
  dialog.querySelector('[data-podcast-transcript-close]').addEventListener('click', closeTranscript);
  dialog.addEventListener('close', () => document.body.classList.remove('garden-scroll-lock'));
  dialog.addEventListener('click', (event) => {
    if (event.target === dialog) closeTranscript();
  });
}
