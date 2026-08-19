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

function parseJsonLines(source) {
  return source
    .split('\n')
    .filter((line) => line.trim())
    .map((line) => JSON.parse(line));
}

function groupTranscript(segments, timeline) {
  if (timeline.length > 0) {
    return timeline.map((section) => ({
      ...section,
      text: segments
        .filter((segment) => segment.end >= section.start && segment.start < section.end)
        .map((segment) => segment.text.trim())
        .join(' ')
    }));
  }

  const groups = [];
  segments.forEach((segment) => {
    const bucket = Math.floor(segment.start / TRANSCRIPT_GROUP_SECONDS);
    let group = groups.at(-1);
    if (!group || group.bucket !== bucket) {
      group = {
        id: `transcript-${bucket}`,
        bucket,
        start: segment.start,
        end: segment.end,
        title: `Transcript at ${formatTimestamp(segment.start)}`,
        text: ''
      };
      groups.push(group);
    }
    group.end = segment.end;
    group.text += `${group.text ? ' ' : ''}${segment.text.trim()}`;
  });
  return groups;
}

function createTranscriptSection(group) {
  const section = document.createElement('article');
  const heading = document.createElement('h3');
  const timestamp = document.createElement('time');
  const paragraph = document.createElement('p');

  section.className = 'course-transcript-section';
  section.dataset.sectionId = group.id;
  section.dataset.start = group.start;
  section.dataset.searchText = `${group.title} ${group.text}`.toLowerCase();
  timestamp.dateTime = `PT${Math.floor(group.start)}S`;
  timestamp.textContent = formatTimestamp(group.start);
  heading.textContent = group.title;
  paragraph.textContent = group.text;
  section.append(timestamp, heading, paragraph);
  return section;
}

function makeSectionButton(label, icon, handler) {
  const button = document.createElement('button');
  const iconElement = document.createElement('i');
  button.type = 'button';
  iconElement.className = `fas ${icon}`;
  iconElement.setAttribute('aria-hidden', 'true');
  button.append(iconElement, label);
  button.addEventListener('click', handler);
  return button;
}

export function initCourseWorkbench() {
  const root = document.querySelector('[data-course-workbench]');
  if (!root) return;

  const tabs = [...root.querySelectorAll('[data-course-tab]')];
  const panels = [...root.querySelectorAll('[data-course-panel]')];
  const sectionSync = root.querySelector('[data-course-section-sync]');
  const sectionSelect = root.querySelector('[data-course-section-select]');
  const sectionTime = root.querySelector('[data-course-section-time]');
  const sectionTitle = root.querySelector('[data-course-section-title]');
  const slideImage = root.querySelector('[data-course-slide-image]');
  const slidePosition = root.querySelector('[data-course-slide-position]');
  const slideTitle = root.querySelector('[data-course-slide-title]');
  const slideNumber = root.querySelector('[data-course-slide-number]');
  const slideStatus = root.querySelector('[data-course-slide-status]');
  const transcriptContent = root.querySelector('[data-course-transcript-content]');
  const transcriptStatus = root.querySelector('[data-course-transcript-status]');
  const transcriptSearch = root.querySelector('[data-course-transcript-search]');
  const executableNotesContent = root.querySelector('[data-course-executable-notes-content]');
  const executableNotesStatus = root.querySelector('[data-course-executable-notes-status]');
  const videoFrame = root.querySelector('[data-course-video-frame]');
  let timeline = [];
  let activeSection = null;
  let slidePages = [];
  let slideIndex = 0;
  let transcriptSections = [];
  let slidesLoading = null;
  let transcriptLoading = null;
  let executableNotesLoading = null;

  const selectTab = (name) => {
    tabs.forEach((tab) => {
      const selected = tab.dataset.courseTab === name;
      tab.setAttribute('aria-selected', selected);
      tab.tabIndex = selected ? 0 : -1;
    });
    panels.forEach((panel) => {
      panel.hidden = panel.dataset.coursePanel !== name;
    });
    if (name === 'slides') loadSlides();
    if (name === 'transcript') loadTranscript();
    if (name === 'executable-notes') loadExecutableNotes();
  };

  const showSlide = (index) => {
    if (slidePages.length === 0 || !slideImage) return;
    slideIndex = Math.min(Math.max(index, 0), slidePages.length - 1);
    const slide = slidePages[slideIndex];
    slideImage.src = slide.src;
    slideImage.alt = `Slide ${slide.page}: ${slide.title || 'Untitled slide'}`;
    slideImage.hidden = false;
    slidePosition.textContent = `Slide ${slide.page} of ${slidePages.length}`;
    slideTitle.textContent = slide.title || '';
    slideNumber.value = slide.page;
    root.querySelector('[data-course-slide-previous]').disabled = slideIndex === 0;
    root.querySelector('[data-course-slide-next]').disabled = slideIndex === slidePages.length - 1;
  };

  const showSlidePage = (page) => {
    const exactIndex = slidePages.findIndex((slide) => slide.page === Number(page));
    if (exactIndex >= 0) showSlide(exactIndex);
  };

  const loadSlides = () => {
    if (!root.dataset.slidesUrl || slidesLoading) return slidesLoading;
    slideStatus.textContent = 'Loading slides…';
    slidesLoading = fetch(root.dataset.slidesUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`Slides request failed: ${response.status}`);
        return response.json();
      })
      .then((manifest) => {
        slidePages = manifest.pages || [];
        if (slidePages.length === 0) throw new Error('Slides manifest contains no pages');
        slideNumber.max = Math.max(...slidePages.map((slide) => slide.page));
        slideStatus.textContent = `${slidePages.length} rendered slides · original PPTX remains available`;
        showSlide(0);
        if (activeSection?.slides?.length) showSlidePage(activeSection.slides[0]);
      })
      .catch(() => {
        slideStatus.textContent = 'Rendered slides could not be loaded. Use the original PPTX download instead.';
      });
    return slidesLoading;
  };

  const loadExecutableNotes = () => {
    if (!root.dataset.executableNotesUrl || executableNotesLoading) return executableNotesLoading;
    executableNotesStatus.textContent = 'Loading executable lecture notes…';
    executableNotesLoading = fetch(root.dataset.executableNotesUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`Executable notes request failed: ${response.status}`);
        return response.text();
      })
      .then((source) => {
        const normalizedSource = source.replace(/\r\n/g, '\n');
        const lineCount = normalizedSource.split('\n').length - (normalizedSource.endsWith('\n') ? 1 : 0);
        executableNotesContent.textContent = normalizedSource;
        executableNotesStatus.textContent = `${lineCount} lines · official executable lecture source`;
      })
      .catch(() => {
        executableNotesStatus.textContent = 'Executable lecture notes could not be loaded. Use the download or official source link.';
      });
    return executableNotesLoading;
  };

  const updateTranscriptSearch = () => {
    const query = transcriptSearch.value.trim().toLowerCase();
    let visible = 0;
    transcriptSections.forEach((section) => {
      const matches = !query || section.dataset.searchText.includes(query);
      section.hidden = !matches;
      if (matches) visible += 1;
    });
    transcriptStatus.textContent = query
      ? `${visible} of ${transcriptSections.length} transcript sections`
      : `${transcriptSections.length} transcript sections aligned with the notes`;
  };

  const jumpTranscript = (sectionId) => {
    const target = transcriptSections.find((section) => section.dataset.sectionId === sectionId);
    if (!target) return;
    transcriptSections.forEach((section) => section.classList.remove('is-target'));
    target.hidden = false;
    target.classList.add('is-target');
    target.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  };

  const loadTranscript = () => {
    if (!root.dataset.transcriptUrl || transcriptLoading) return transcriptLoading;
    transcriptStatus.textContent = 'Loading transcript…';
    transcriptLoading = fetch(root.dataset.transcriptUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`Transcript request failed: ${response.status}`);
        return response.text();
      })
      .then((source) => {
        const fragment = document.createDocumentFragment();
        groupTranscript(parseJsonLines(source), timeline).forEach((group) => {
          fragment.append(createTranscriptSection(group));
        });
        transcriptContent.append(fragment);
        transcriptSections = [...transcriptContent.querySelectorAll('.course-transcript-section')];
        updateTranscriptSearch();
        if (activeSection) jumpTranscript(activeSection.id);
      })
      .catch(() => {
        transcriptStatus.textContent = 'The transcript could not be loaded. Use the plain-text download instead.';
      });
    return transcriptLoading;
  };

  const seekVideo = (seconds) => {
    if (videoFrame && root.dataset.primaryProvider === 'youtube') {
      videoFrame.contentWindow.postMessage(
        JSON.stringify({ event: 'command', func: 'seekTo', args: [seconds, true] }),
        '*'
      );
      return;
    }
    if (root.dataset.videoSeekTemplate) {
      window.open(
        root.dataset.videoSeekTemplate.replace('{seconds}', Math.floor(seconds)),
        '_blank',
        'noopener,noreferrer'
      );
    }
  };

  const activateSection = (section, resource = null) => {
    activeSection = section;
    sectionSelect.value = section.id;
    sectionTime.textContent = `${formatTimestamp(section.start)}–${formatTimestamp(section.end)}`;
    sectionTitle.textContent = section.title;
    document.querySelectorAll('[data-course-note-section]').forEach((heading) => {
      heading.classList.toggle('is-active', heading.id === section.note_anchor);
    });

    if (section.slides?.length) {
      loadSlides()?.then(() => showSlidePage(section.slides[0]));
    }
    if (resource === 'slides') selectTab('slides');
    if (resource === 'transcript') {
      selectTab('transcript');
      loadTranscript()?.then(() => jumpTranscript(section.id));
    }
    if (resource === 'video') {
      selectTab('video');
      seekVideo(section.start);
    }
  };

  const annotateNotes = () => {
    timeline.forEach((section) => {
      const anchor = document.getElementById(section.note_anchor);
      if (!anchor) return;
      const heading = anchor.matches('h2, h3, h4') ? anchor : anchor.nextElementSibling;
      if (!heading?.matches('h2, h3, h4')) return;
      heading.dataset.courseNoteSection = section.id;
      const tools = document.createElement('div');
      const timestamp = document.createElement('time');
      tools.className = 'course-note-section-tools';
      timestamp.dateTime = `PT${Math.floor(section.start)}S`;
      timestamp.textContent = `${formatTimestamp(section.start)}–${formatTimestamp(section.end)}`;
      tools.append(timestamp);
      if (root.querySelector('[data-course-panel="video"]')) {
        tools.append(makeSectionButton('Video', 'fa-circle-play', () => activateSection(section, 'video')));
      }
      if (root.querySelector('[data-course-panel="slides"]') && section.slides?.length) {
        tools.append(
          makeSectionButton(
            `Slides ${section.slides.map((page) => `p.${page}`).join(', ')}`,
            'fa-display',
            () => activateSection(section, 'slides')
          )
        );
      }
      if (root.querySelector('[data-course-panel="transcript"]')) {
        tools.append(makeSectionButton('Transcript', 'fa-align-left', () => activateSection(section, 'transcript')));
      }
      heading.insertAdjacentElement('afterend', tools);
    });
  };

  const loadTimeline = () => {
    if (!root.dataset.timelineUrl) return Promise.resolve();
    return fetch(root.dataset.timelineUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`Timeline request failed: ${response.status}`);
        return response.json();
      })
      .then((data) => {
        timeline = data.sections || [];
        if (timeline.length === 0) return;
        const options = document.createDocumentFragment();
        timeline.forEach((section, index) => {
          const option = document.createElement('option');
          option.value = section.id;
          option.textContent = `${String(index + 1).padStart(2, '0')} · ${formatTimestamp(section.start)} · ${section.title}`;
          options.append(option);
        });
        sectionSelect.append(options);
        sectionSync.hidden = false;
        annotateNotes();
        activateSection(timeline[0]);
      });
  };

  tabs.forEach((tab, index) => {
    tab.addEventListener('click', () => selectTab(tab.dataset.courseTab));
    tab.addEventListener('keydown', (event) => {
      if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
      const direction = event.key === 'ArrowRight' ? 1 : -1;
      const next = tabs[(index + direction + tabs.length) % tabs.length];
      next.focus();
      selectTab(next.dataset.courseTab);
    });
  });

  document.querySelectorAll('[data-course-open-resource]').forEach((button) => {
    button.addEventListener('click', () => {
      selectTab(button.dataset.courseOpenResource);
      root.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });

  if (sectionSelect) {
    sectionSelect.addEventListener('change', () => {
      const section = timeline.find((item) => item.id === sectionSelect.value);
      if (section) activateSection(section);
    });
    root.querySelectorAll('[data-course-section-resource]').forEach((button) => {
      button.addEventListener('click', () => {
        if (activeSection) activateSection(activeSection, button.dataset.courseSectionResource);
      });
    });
    root.querySelector('[data-course-section-notes]').addEventListener('click', () => {
      if (!activeSection) return;
      document.getElementById(activeSection.note_anchor)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  }

  if (slideImage) {
    root.querySelector('[data-course-slide-previous]').addEventListener('click', () => showSlide(slideIndex - 1));
    root.querySelector('[data-course-slide-next]').addEventListener('click', () => showSlide(slideIndex + 1));
    slideNumber.addEventListener('change', () => showSlidePage(slideNumber.value));
  }
  if (transcriptSearch) transcriptSearch.addEventListener('input', updateTranscriptSearch);

  loadTimeline().catch(() => {
    if (sectionSync) sectionSync.hidden = true;
  });
}
