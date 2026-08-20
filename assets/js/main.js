// Main JavaScript for Pack 338 Website
//
// Upcoming events used to be fetched here from the Groups.io .ics feed through
// public CORS proxies. Those proxies went down and took the events widget with
// them, so the feed is now fetched at build time by script/fetch-events.rb and
// rendered from _data/events.yml — see _includes/upcoming-events.html.

document.addEventListener('DOMContentLoaded', function () {
    // Smooth scrolling for anchor links on the current page. Links pointing at
    // another page (e.g. "/#about" from /signup/) are left alone so the browser
    // navigates normally — calling preventDefault() unconditionally used to make
    // the whole nav dead on the signup page.
    document.querySelectorAll('a[href*="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            let url;
            try {
                url = new URL(this.href, window.location.href);
            } catch (error) {
                return;
            }

            if (url.origin !== window.location.origin) return;
            if (url.pathname !== window.location.pathname) return;
            if (!url.hash || url.hash === '#') return;

            const target = document.getElementById(decodeURIComponent(url.hash.slice(1)));
            if (!target) return;

            e.preventDefault();
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        });
    });
});
