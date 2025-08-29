// Main JavaScript for Pack 338 Website

// Function to load upcoming events from iCal feed
async function loadUpcomingEvents() {
    const eventsList = document.getElementById('events-list');
    if (!eventsList) return;

    // Add timeout to prevent infinite loading
    const timeout = setTimeout(() => {
        eventsList.innerHTML = `
            <div class="no-events">
                <i class="fas fa-clock me-2"></i>
                Taking a bit longer than usual...
                <br><small class="text-muted">Check our Groups.io group below for events</small>
            </div>
        `;
    }, 15000); // 15 second timeout

    try {
        // Try multiple CORS proxies in case one fails
        const proxies = [
            'https://api.allorigins.win/raw?url=',
            'https://cors-anywhere.herokuapp.com/',
            'https://thingproxy.freeboard.io/fetch/'
        ];

        let icalData = null;
        let lastError = null;

        // Try each proxy until one works
        for (const proxy of proxies) {
            try {
                const url = proxy + encodeURIComponent('https://pack338.groups.io/g/all/ics/12344147/2126990759/feed.ics');
                console.log('Trying proxy:', proxy);

                const response = await fetch(url, {
                    method: 'GET',
                    headers: {
                        'Accept': 'text/plain',
                        'User-Agent': 'Mozilla/5.0 (compatible; Pack338Website/1.0)'
                    }
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                icalData = await response.text();
                console.log('Successfully fetched iCal data from:', proxy);
                break;

            } catch (error) {
                console.log('Proxy failed:', proxy, error.message);
                lastError = error;
                continue;
            }
        }

        if (!icalData) {
            throw new Error('All CORS proxies failed: ' + lastError?.message);
        }

        clearTimeout(timeout); // Clear timeout on success
        const events = parseICalData(icalData);
        displayEvents(events);

    } catch (error) {
        clearTimeout(timeout); // Clear timeout on error
        console.error('Error loading events:', error);

        // Show error message if iCal feed fails
        showEventError(error.message);
    }
}

// Parse iCal data and extract upcoming events
function parseICalData(icalData) {
    const events = [];
    const lines = icalData.split('\n');
    let currentEvent = {};
    let inEvent = false;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();

        if (line === 'BEGIN:VEVENT') {
            inEvent = true;
            currentEvent = {};
        } else if (line === 'END:VEVENT') {
            if (inEvent && currentEvent.summary) {
                events.push(currentEvent);
            }
            inEvent = false;
        } else if (inEvent) {
            if (line.startsWith('SUMMARY:')) {
                currentEvent.summary = line.substring(8);
            } else if (line.startsWith('DTSTART:')) {
                currentEvent.start = parseICalDate(line.substring(8));
            } else if (line.startsWith('DTEND:')) {
                currentEvent.end = parseICalDate(line.substring(6));
            } else if (line.startsWith('URL:')) {
                currentEvent.url = line.substring(4);
            }
        }
    }

    // Filter for future events and sort by date
    const now = new Date();
    return events
        .filter(event => event.start && event.start > now)
        .sort((a, b) => a.start - b.start)
        .slice(0, 5); // Show next 5 events
}

// Parse iCal date format
function parseICalDate(dateStr) {
    // Handle different iCal date formats
    if (dateStr.includes('T')) {
        // Date with time
        return new Date(dateStr.replace(/(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z?/, '$1-$2-$3T$4:$5:$6Z'));
    } else {
        // Date only
        return new Date(dateStr.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3'));
    }
}

// Display events in the UI
function displayEvents(events) {
    const eventsList = document.getElementById('events-list');
    if (!eventsList) return;

    if (events.length === 0) {
        eventsList.innerHTML = `
            <div class="no-events">
                <i class="fas fa-calendar-times me-2"></i>
                No upcoming events at this time
            </div>
        `;
        return;
    }

    const eventsHTML = events.map(event => {
        const startDate = event.start.toLocaleDateString('en-US', {
            weekday: 'long',
            month: 'long',
            day: 'numeric',
            year: 'numeric'
        });

        const startTime = event.start.getHours() !== 0 ? event.start.toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit',
            timeZoneName: 'short'
        }) : '';

        const endTime = event.end ? event.end.toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit',
            timeZoneName: 'short'
        }) : '';

        // Make title clickable if URL exists
        const titleHTML = event.url ?
            `<a href="${event.url}" target="_blank" class="event-title-link">${event.summary}</a>` :
            event.summary;

        return `
            <div class="event-item">
                <div class="event-date">
                    <i class="fas fa-calendar-day me-2"></i>
                    ${startDate}${event.start.getHours() !== 0 ? ` at ${startTime}` : ''}${endTime ? ` - ${endTime}` : ''}
                </div>
                <div class="event-title">
                    <i class="fas fa-flag me-2"></i>
                    ${titleHTML}
                </div>
            </div>
        `;
    }).join('');

    // Add calendar link below events
    const calendarLink = `
        <div class="calendar-link">
            <a href="https://pack338.groups.io/g/all/calendar" target="_blank" class="btn btn-outline-light btn-sm">
                <i class="fas fa-calendar-alt me-2"></i>
                View Full Pack Calendar
            </a>
        </div>
    `;

    eventsList.innerHTML = eventsHTML + calendarLink;
}

// Show error message when iCal feed is unavailable
function showEventError(errorMessage) {
    const eventsList = document.getElementById('events-list');
    if (!eventsList) return;

    eventsList.innerHTML = `
        <div class="event-error">
            <i class="fas fa-info-circle me-2"></i>
            <strong>Events Temporarily Unavailable</strong>
            <br><small class="text-muted">Our calendar feed is having a moment</small>
            <br><small class="text-muted">Check our <a href="https://pack338.groups.io/g/all/calendar" target="_blank" class="text-white">Groups.io calendar</a> for current events</small>
        </div>
    `;
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Load upcoming events if the element exists
    if (document.getElementById('events-list')) {
        loadUpcomingEvents();
    }
    
    // Add smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});
