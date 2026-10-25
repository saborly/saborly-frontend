"""Generates the crawlable video pages for saborly.es.

The Flutter site renders to a canvas, so search engines and AI crawlers (most
of which don't run JavaScript) can't read it. These plain-HTML pages give each
video a real, indexable watch page with structured data:

  web/videos/index.html            hub: all videos + FAQ (FAQPage) + locations
  web/videos/<slug>/index.html     one watch page per video (VideoObject)
  web/llms.txt                     site summary for AI assistants (llmstxt.org)
  web/sitemap.xml                  <video:video> entries (between markers)
  web/index.html                   links in the crawler fallback (between markers)

nginx serves real files before falling back to the Flutter app
(try_files $uri $uri/ /index.html), and `flutter build web` copies web/ into
the build, so no server change is needed.

Usage (from the project root; needs ffprobe on PATH):
    python tool/seo/build_video_pages.py
Re-run after changing tool/seo/videos_data.py or the video files.
"""
import html
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
from videos_data import FAQ, LOCATIONS, PUBLISHED, SITE, TAGS, VIDEOS  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
WEB = os.path.join(ROOT, 'web')
VIDEO_DIR = os.path.join(ROOT, 'assets', 'videos', 'optimized')
POSTER_DIR = os.path.join(ROOT, 'assets', 'videos', 'posters')
# Flutter web serves app assets under /assets/<asset key>.
VIDEO_URL = SITE + '/assets/assets/videos/optimized/saborly_{id}.mp4'
POSTER_URL = SITE + '/assets/assets/videos/posters/saborly_{id}.jpg'
LOGO_URL = SITE + '/assets/assets/images/logo3.png'
HUB_URL = SITE + '/videos/'
UPLOAD_DATE = PUBLISHED + 'T00:00:00+02:00'

esc = html.escape


def probe(path, video=True):
    """(width, height, seconds) of a video, or (width, height, None) of an image."""
    fields = 'stream=width,height' + (':format=duration' if video else '')
    out = subprocess.run(
        ['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', fields, '-of', 'json', path],
        capture_output=True, encoding='utf-8', check=True).stdout
    data = json.loads(out)
    stream = data['streams'][0]
    seconds = float(data['format']['duration']) if video else None
    return stream['width'], stream['height'], seconds


def iso_duration(seconds):
    total = int(round(seconds))
    minutes, secs = divmod(total, 60)
    return f'PT{minutes}M{secs}S' if minutes else f'PT{secs}S'


def clock(seconds):
    total = int(seconds)  # floor, like the app's player
    return f'{total // 60}:{total % 60:02d}'


def page_url(video):
    return f'{SITE}/videos/{video["slug"]}/'


def ld(obj):
    # "</" can't appear inside a <script>; JSON allows escaping the slash.
    return json.dumps(obj, ensure_ascii=False, indent=1).replace('</', '<\\/')


def restaurant_node(key):
    loc = LOCATIONS[key]
    node = {
        '@type': 'Restaurant',
        '@id': f'{SITE}/#restaurant' if key == 'bcn' else f'{SITE}/#restaurant-{key}',
        'name': loc['name'],
        'url': SITE,
        'logo': LOGO_URL,
        'image': LOGO_URL,
        'servesCuisine': ['Halal', 'Pakistani', 'Fast Food', 'Burgers', 'Pizza'],
        'email': 'info@saborly.es',
        'address': {
            '@type': 'PostalAddress',
            'streetAddress': loc['street'],
            'addressLocality': loc['locality'],
            'postalCode': loc['postal'],
            'addressRegion': 'Cataluña',
            'addressCountry': 'ES',
        },
    }
    if loc['phone']:
        node['telephone'] = loc['phone']
    if loc['lat'] is not None:
        node['geo'] = {'@type': 'GeoCoordinates', 'latitude': loc['lat'], 'longitude': loc['lng']}
    if key == 'bcn':
        # Same profiles the app's footer links to; ties the entity together.
        node['sameAs'] = ['https://www.instagram.com/saborly.es/', 'https://www.facebook.com/SaborlyBurger/']
    else:
        node['parentOrganization'] = {'@id': f'{SITE}/#restaurant'}
    return node


def address_html(key):
    loc = LOCATIONS[key]
    district = f'{esc(loc["district"])}<br>' if loc['district'] else ''
    phone = (f'<br>Tel: <a href="tel:{loc["phone"]}">{esc(loc["phone_display"])}</a>' if loc['phone'] else '')
    maps = 'https://www.google.com/maps/search/?api=1&query=' + \
        esc(f'Saborly, {loc["street"]}, {loc["postal"]} {loc["locality"]}').replace(' ', '+')
    return (f'<address><strong>{esc(loc["name"])}</strong><br>{esc(loc["street"])}<br>{district}'
            f'{esc(loc["postal"])} {esc(loc["locality"])}{phone}<br>'
            f'<a href="{maps}" rel="noopener">Cómo llegar</a></address>')


CSS = """
:root{--primary:#D84E17;--secondary:#F5A623;--bg:#FBF3E7;--text:#28140E;--muted:#72513E;--light:#A08371;
--border:#E7D3BD;--night:#2A1611;--cream:#FFF7F2;--grad:linear-gradient(135deg,#E46221,#B33E17)}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font:500 16px/1.65 Manrope,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
a{color:var(--primary)}
img,video{max-width:100%}
.wrap{max-width:1180px;margin:0 auto;padding:0 20px}
.site-header{background:#fff;border-bottom:1px solid var(--border);position:sticky;top:0;z-index:10}
.site-header .wrap{display:flex;align-items:center;gap:20px;height:66px}
.site-header img{height:38px;width:auto;display:block}
.site-header nav{margin-left:auto;display:flex;gap:22px;align-items:center;font-weight:700}
.site-header nav a{text-decoration:none;color:var(--muted)}
.site-header nav a[aria-current=page]{color:var(--primary)}
.btn{display:inline-flex;align-items:center;gap:8px;padding:12px 22px;border-radius:999px;font-weight:800;
text-decoration:none;border:1.5px solid var(--border);background:#fff;color:var(--primary);transition:transform .15s}
.btn:hover{transform:translateY(-2px)}
.btn.primary,.site-header nav a.btn{background:var(--grad);color:#fff;border:0;box-shadow:0 8px 20px rgba(216,78,23,.3)}
h1,h2,h3{font-family:"Bree Serif",Georgia,serif;font-weight:400;letter-spacing:-.3px;line-height:1.15}
h2{font-size:clamp(24px,3vw,32px);margin:0 0 18px}
.kicker{display:block;font-size:12px;font-weight:800;letter-spacing:1.6px;text-transform:uppercase;color:var(--primary)}
.rule{width:84px;height:4px;border-radius:999px;background:linear-gradient(90deg,var(--secondary),var(--primary));margin:10px 0 0}
.crumbs{font-size:14px;color:var(--light);margin:24px 0}
.crumbs a{color:var(--muted);text-decoration:none}
.crumbs a:hover{text-decoration:underline}
.watch-grid{display:grid;grid-template-columns:minmax(0,430px) minmax(0,1fr);gap:48px;align-items:start}
.player video{width:100%;height:auto;max-height:84vh;border-radius:26px;background:#000;display:block;
box-shadow:0 22px 50px rgba(42,22,17,.35)}
.tag{display:inline-block;background:var(--grad);color:#fff;font-size:11px;font-weight:800;letter-spacing:1px;
text-transform:uppercase;padding:5px 11px;border-radius:999px}
.info h1{font-size:clamp(32px,4.2vw,48px);margin:14px 0 6px}
.meta{color:var(--muted);font-weight:700;margin:0 0 20px}
.lead{font-size:18px;margin:0 0 20px}
.info h2{font-size:22px;margin:26px 0 8px}
.info ul{margin:0;padding-left:20px}
.ctas{display:flex;flex-wrap:wrap;gap:12px;margin:28px 0}
.en{background:var(--cream);border:1px solid var(--border);border-radius:18px;padding:14px 18px;color:var(--muted);margin:0}
.places{display:grid;gap:14px;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));margin-top:26px}
address{font-style:normal;background:#fff;border:1px solid var(--border);border-radius:20px;padding:18px;line-height:1.55}
.section{margin:72px 0}
.hero{padding:40px 0 8px}
.hero h1{font-size:clamp(36px,5vw,56px);margin:6px 0 0}
.hero p{font-size:18px;max-width:760px;color:var(--muted)}
.panel{background:linear-gradient(180deg,#FFF9F1,#FFF0E1);border:1.5px solid #fff;border-radius:28px;padding:22px;
box-shadow:0 10px 30px rgba(42,22,17,.12)}
.grid{display:grid;gap:18px;grid-template-columns:repeat(auto-fill,minmax(180px,1fr))}
.card{position:relative;display:block;border-radius:22px;overflow:hidden;aspect-ratio:9/16;background:var(--night);
text-decoration:none;box-shadow:0 10px 24px rgba(42,22,17,.22);transition:transform .2s,box-shadow .2s}
.card:hover{transform:translateY(-5px);box-shadow:0 18px 34px rgba(42,22,17,.32)}
.card img{width:100%;height:100%;object-fit:cover;display:block}
.card::after{content:"";position:absolute;inset:0;
background:linear-gradient(180deg,rgba(0,0,0,.35) 0,transparent 22%,transparent 48%,rgba(18,9,6,.93) 100%)}
.card .tag{position:absolute;top:10px;left:10px;z-index:1;background:rgba(255,255,255,.94);color:var(--primary)}
.card .play{position:absolute;top:50%;left:50%;width:52px;height:52px;margin:-26px 0 0 -26px;border-radius:50%;z-index:1;
background:rgba(255,255,255,.92);box-shadow:0 6px 18px rgba(0,0,0,.25)}
.card .play::before{content:"";position:absolute;left:21px;top:16px;border-style:solid;border-width:10px 0 10px 16px;
border-color:transparent transparent transparent var(--primary)}
.card .t{position:absolute;left:14px;right:14px;bottom:14px;z-index:1;color:#fff;font-weight:800;line-height:1.25}
.card .d{display:block;font-weight:700;font-size:12px;color:rgba(255,255,255,.85);margin-top:5px}
.faq details{background:#fff;border:1px solid var(--border);border-radius:18px;padding:16px 20px;margin:12px 0}
.faq summary{font-weight:800;cursor:pointer}
.faq details p{margin:10px 0 0;color:var(--muted)}
.about p{max-width:820px}
footer{background:var(--night);color:#F6E4CF;padding:40px 0;margin-top:72px;font-size:14px}
footer a{color:#fff}
@media (max-width:820px){.watch-grid{grid-template-columns:1fr;gap:28px}.player{max-width:430px;margin:0 auto;width:100%}
.site-header nav a:not(.btn){display:none}.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
"""


def head(title, description, url, og_type='website', image=None, extra_meta='', jsonld=None):
    image = image or LOGO_URL
    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<meta name="description" content="{esc(description)}">
<meta name="robots" content="index, follow, max-image-preview:large, max-video-preview:-1">
<link rel="canonical" href="{url}">
<link rel="alternate" hreflang="es" href="{url}">
<link rel="alternate" hreflang="x-default" href="{url}">
<meta name="theme-color" content="#D84E17">
<meta property="og:site_name" content="Saborly">
<meta property="og:locale" content="es_ES">
<meta property="og:type" content="{og_type}">
<meta property="og:title" content="{esc(title)}">
<meta property="og:description" content="{esc(description)}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{image}">
{extra_meta}<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{esc(title)}">
<meta name="twitter:description" content="{esc(description)}">
<meta name="twitter:image" content="{image}">
<link rel="icon" type="image/png" href="/favicon.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bree+Serif&family=Manrope:wght@500;700;800&display=swap">
<style>{CSS.strip()}</style>
<script type="application/ld+json">
{ld(jsonld)}
</script>
</head>
<body>
<header class="site-header"><div class="wrap">
<a href="/" aria-label="Saborly – inicio"><img src="/assets/assets/images/logo3.png" alt="Saborly" width="124" height="38"></a>
<nav aria-label="Principal"><a href="/menu">Menú</a><a href="/offer">Ofertas</a>
<a href="/videos/"{' aria-current="page"' if url == HUB_URL else ''}>Vídeos</a><a class="btn" href="/menu">Pedir ahora</a></nav>
</div></header>
"""


FOOTER = f"""<footer><div class="wrap">
<p><strong>Saborly</strong> · Comida rápida 100 % halal de estilo paquistaní en Barcelona y Sabadell.</p>
<p>{esc(LOCATIONS['bcn']['street'])}, {LOCATIONS['bcn']['postal']} Barcelona · {esc(LOCATIONS['sbd']['street'])}, {LOCATIONS['sbd']['postal']} Sabadell ·
<a href="tel:{LOCATIONS['bcn']['phone']}">{LOCATIONS['bcn']['phone_display']}</a> · <a href="mailto:info@saborly.es">info@saborly.es</a></p>
<p><a href="/menu">Pedir online</a> · <a href="/videos/">Vídeos</a> · <a href="/privacy.html">Privacidad</a></p>
</div></footer>
</body>
</html>
"""


def card(video):
    tag = TAGS[video['tag']][0]
    return (f'<a class="card" href="/videos/{video["slug"]}/">'
            f'<img src="{POSTER_URL.format(id=video["id"])}" alt="{esc(video["title"])}" loading="lazy" '
            f'width="{video["poster_w"]}" height="{video["poster_h"]}">'
            f'<span class="tag">{esc(tag)}</span><span class="play" aria-hidden="true"></span>'
            f'<span class="t">{esc(video["title"])}<span class="d">▶ {clock(video["seconds"])}</span></span></a>')


def video_object(video, with_context=False):
    obj = {
        '@type': 'VideoObject',
        '@id': page_url(video) + '#video',
        'name': video['title'],
        'description': video['description'],
        'thumbnailUrl': [POSTER_URL.format(id=video['id'])],
        'uploadDate': UPLOAD_DATE,
        'duration': iso_duration(video['seconds']),
        'contentUrl': VIDEO_URL.format(id=video['id']),
        'encodingFormat': 'video/mp4',
        'width': video['w'],
        'height': video['h'],
        'inLanguage': 'es',
        'isFamilyFriendly': True,
        'keywords': ', '.join(video['keywords']),
        'mainEntityOfPage': page_url(video),
        'publisher': {'@id': f'{SITE}/#restaurant'},
        'contentLocation': [{'@id': restaurant_node(k)['@id']} for k in video['locations']],
    }
    if with_context:
        obj['@context'] = 'https://schema.org'
    return obj


def watch_page(video, others):
    url = page_url(video)
    tag_es, _ = TAGS[video['tag']]
    title = f'{video["title"]} – Vídeo | Saborly, comida halal en Barcelona y Sabadell'
    meta = video['description']
    if len(meta) > 158:
        meta = meta[:155].rsplit(' ', 1)[0] + '…'
    where = ' y '.join(LOCATIONS[k]['locality'] for k in video['locations'])
    graph = {
        '@context': 'https://schema.org',
        '@graph': [
            restaurant_node('bcn'),
            *([restaurant_node('sbd')] if 'sbd' in video['locations'] else []),
            video_object(video),
            {'@type': 'BreadcrumbList', 'itemListElement': [
                {'@type': 'ListItem', 'position': 1, 'name': 'Inicio', 'item': SITE + '/'},
                {'@type': 'ListItem', 'position': 2, 'name': 'Vídeos', 'item': HUB_URL},
                {'@type': 'ListItem', 'position': 3, 'name': video['title'], 'item': url},
            ]},
        ],
    }
    og_video = (f'<meta property="og:video" content="{VIDEO_URL.format(id=video["id"])}">\n'
                f'<meta property="og:video:secure_url" content="{VIDEO_URL.format(id=video["id"])}">\n'
                f'<meta property="og:video:type" content="video/mp4">\n'
                f'<meta property="og:video:width" content="{video["w"]}">\n'
                f'<meta property="og:video:height" content="{video["h"]}">\n')
    points = ''.join(f'<li>{esc(p)}</li>' for p in video['points'])
    places = ''.join(address_html(k) for k in video['locations'])
    related = ''.join(card(v) for v in others)
    return head(title, meta, url, og_type='video.other', image=POSTER_URL.format(id=video['id']),
                extra_meta=og_video, jsonld=graph) + f"""<main class="wrap">
<nav class="crumbs" aria-label="Migas de pan"><a href="/">Inicio</a> › <a href="/videos/">Vídeos</a> › <span>{esc(video['title'])}</span></nav>
<div class="watch-grid">
<div class="player">
<video controls playsinline preload="metadata" poster="{POSTER_URL.format(id=video['id'])}" width="{video['w']}" height="{video['h']}" aria-label="{esc(video['title'])}">
<source src="{VIDEO_URL.format(id=video['id'])}" type="video/mp4">
Tu navegador no puede reproducir este vídeo. <a href="{VIDEO_URL.format(id=video['id'])}">Descárgalo aquí</a>.
</video>
</div>
<article class="info">
<span class="tag">{esc(tag_es)}</span>
<h1>{esc(video['title'])}</h1>
<p class="meta">▶ {clock(video['seconds'])} · Saborly {esc(where)}</p>
<p class="lead">{esc(video['description'])}</p>
<h2>En este vídeo</h2>
<ul>{points}</ul>
<div class="ctas"><a class="btn primary" href="/menu">Ver el menú y pedir</a><a class="btn" href="/videos/">Más vídeos</a></div>
<p class="en" lang="en"><strong>In English:</strong> {esc(video['en'])}</p>
<div class="places">{places}</div>
</article>
</div>
<section class="section">
<span class="kicker">Mira</span><h2>Más vídeos de Saborly</h2>
<div class="panel"><div class="grid">{related}</div></div>
</section>
</main>
""" + FOOTER


def hub_page():
    description = ('Vídeos de Saborly, comida rápida 100 % halal de estilo paquistaní en Barcelona y Sabadell: '
                   'nuestras burgers, pizzas, tacos y mocktails, reseñas de clientes y eventos.')
    graph = {
        '@context': 'https://schema.org',
        '@graph': [
            restaurant_node('bcn'),
            restaurant_node('sbd'),
            {
                '@type': 'CollectionPage',
                '@id': HUB_URL + '#page',
                'url': HUB_URL,
                'name': 'Vídeos de Saborly',
                'description': description,
                'inLanguage': 'es',
                'isPartOf': {'@type': 'WebSite', 'name': 'Saborly', 'url': SITE},
                'about': {'@id': f'{SITE}/#restaurant'},
                'mainEntity': {
                    '@type': 'ItemList',
                    'numberOfItems': len(VIDEOS),
                    'itemListElement': [
                        {'@type': 'ListItem', 'position': i + 1, 'url': page_url(v), 'name': v['title']}
                        for i, v in enumerate(VIDEOS)
                    ],
                },
            },
            {
                '@type': 'FAQPage',
                'mainEntity': [
                    {'@type': 'Question', 'name': q, 'acceptedAnswer': {'@type': 'Answer', 'text': a}}
                    for q, a in FAQ
                ],
            },
            {'@type': 'BreadcrumbList', 'itemListElement': [
                {'@type': 'ListItem', 'position': 1, 'name': 'Inicio', 'item': SITE + '/'},
                {'@type': 'ListItem', 'position': 2, 'name': 'Vídeos', 'item': HUB_URL},
            ]},
        ],
    }
    cards = ''.join(card(v) for v in VIDEOS)
    faq = ''.join(f'<details><summary>{esc(q)}</summary><p>{esc(a)}</p></details>' for q, a in FAQ)
    return head('Vídeos de Saborly – Comida halal en Barcelona y Sabadell', description, HUB_URL,
                image=POSTER_URL.format(id=VIDEOS[0]['id']), jsonld=graph) + f"""<main class="wrap">
<section class="hero">
<nav class="crumbs" aria-label="Migas de pan"><a href="/">Inicio</a> › <span>Vídeos</span></nav>
<span class="kicker">Mira</span>
<h1>Vídeos de Saborly</h1>
<div class="rule"></div>
<p>Saborly es un restaurante de comida rápida 100 % halal de estilo paquistaní con dos locales: en Barcelona
(C/ de Pere IV, 208, Sant Martí – Poblenou) y en Sabadell (Av. Francesc Macià, 47). Aquí puedes ver nuestros platos,
nuestros locales y lo que cuentan clientes, creadores de contenido e invitados especiales.</p>
<div class="ctas"><a class="btn primary" href="/menu">Ver el menú y pedir</a></div>
</section>
<section class="section" style="margin-top:28px">
<div class="panel"><div class="grid">{cards}</div></div>
</section>
<section class="section about">
<span class="kicker">Sobre Saborly</span><h2>Comida halal de estilo paquistaní</h2>
<p>En Saborly preparamos burgers y smash burgers, pizzas, tacos de pollo, pollo frito y a la parrilla, palitos de
mozzarella, batidos, mocktails sin alcohol y postres como la tarta Red Velvet. Toda la carta es 100 % halal y puedes
pedir online en <a href="/menu">saborly.es</a> para entrega a domicilio o recogida en el local.</p>
<p class="en" lang="en"><strong>In English:</strong> Saborly is a 100% halal, Pakistani-style fast-food restaurant with
locations in Barcelona (C/ de Pere IV 208, Poblenou) and Sabadell (Av. Francesc Macià 47) — burgers, smash burgers,
pizzas, chicken tacos, milkshakes, alcohol-free mocktails and desserts. Order online at saborly.es for delivery or
pickup.</p>
<div class="places">{address_html('bcn')}{address_html('sbd')}</div>
</section>
<section class="section faq">
<span class="kicker">Preguntas frecuentes</span><h2>Lo que más nos preguntáis</h2>
{faq}
</section>
</main>
""" + FOOTER


def llms_txt():
    lines = [
        '# Saborly',
        '',
        '> Saborly is a 100% halal, Pakistani-style fast-food restaurant in Barcelona (C/ de Pere IV, 208, '
        'Sant Martí – Poblenou, 08005) and Sabadell (Av. Francesc Macià, 47, 08206), Spain. Burgers, smash burgers, '
        'pizzas, chicken tacos, fried and grilled chicken, milkshakes, alcohol-free mocktails and desserts. '
        'Order online at https://saborly.es for delivery or pickup.',
        '',
        'Saborly es un restaurante de comida rápida 100 % halal de estilo paquistaní en Barcelona y Sabadell. '
        'Pedido online con entrega a domicilio o recogida.',
        '',
        '- Phone (Barcelona): ' + LOCATIONS['bcn']['phone_display'],
        '- Email: info@saborly.es',
        '- Languages on the site: Español, English, Català, العربية, Français',
        '',
        '## Order',
        '',
        f'- [Menu and online ordering]({SITE}/menu): full menu, delivery or pickup',
        f'- [Offers]({SITE}/offer): current deals and combos',
        '',
        '## Videos',
        '',
        f'- [All Saborly videos]({HUB_URL}): dishes, locations, customer reviews and events, with FAQ',
    ]
    for v in VIDEOS:
        lines.append(f'- [{v["title"]}]({page_url(v)}): {v["en"]}')
    lines += ['', '## Optional', '', f'- [Privacy policy]({SITE}/privacy.html)', '']
    return '\n'.join(lines)


def sitemap_entries():
    out = ['  <url>', f'    <loc>{HUB_URL}</loc>', f'    <lastmod>{PUBLISHED}</lastmod>',
           '    <changefreq>weekly</changefreq>', '    <priority>0.7</priority>', '  </url>']
    for v in VIDEOS:
        out += [
            '  <url>',
            f'    <loc>{page_url(v)}</loc>',
            f'    <lastmod>{PUBLISHED}</lastmod>',
            '    <changefreq>monthly</changefreq>',
            '    <priority>0.6</priority>',
            '    <video:video>',
            f'      <video:thumbnail_loc>{POSTER_URL.format(id=v["id"])}</video:thumbnail_loc>',
            f'      <video:title>{esc(v["title"])}</video:title>',
            f'      <video:description>{esc(v["description"])}</video:description>',
            f'      <video:content_loc>{VIDEO_URL.format(id=v["id"])}</video:content_loc>',
            f'      <video:duration>{int(round(v["seconds"]))}</video:duration>',
            f'      <video:publication_date>{UPLOAD_DATE}</video:publication_date>',
            '      <video:family_friendly>yes</video:family_friendly>',
            '    </video:video>',
            '  </url>',
        ]
    return '\n'.join(out)


def replace_between(text, start, end, body, file):
    pattern = re.compile(re.escape(start) + r'.*?' + re.escape(end), re.S)
    if not pattern.search(text):
        sys.exit(f'Markers {start} … {end} not found in {file}')
    return pattern.sub(lambda _: f'{start}\n{body}\n{end}', text)


def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(content)


def main():
    for v in VIDEOS:
        v['w'], v['h'], v['seconds'] = probe(os.path.join(VIDEO_DIR, f'saborly_{v["id"]}.mp4'))
        v['poster_w'], v['poster_h'], _ = probe(os.path.join(POSTER_DIR, f'saborly_{v["id"]}.jpg'), video=False)

    write(os.path.join(WEB, 'videos', 'index.html'), hub_page())
    for i, v in enumerate(VIDEOS):
        # Related: the next six videos, wrapping around.
        others = [VIDEOS[(i + k) % len(VIDEOS)] for k in range(1, 7)]
        write(os.path.join(WEB, 'videos', v['slug'], 'index.html'), watch_page(v, others))
    write(os.path.join(WEB, 'llms.txt'), llms_txt())

    sitemap_path = os.path.join(WEB, 'sitemap.xml')
    sitemap = open(sitemap_path, encoding='utf-8').read()
    if 'xmlns:video=' not in sitemap:
        sitemap = sitemap.replace('<urlset ', '<urlset xmlns:video="http://www.google.com/schemas/sitemap-video/1.1"\n        ', 1)
    if '<!-- videos:start -->' not in sitemap:
        sitemap = sitemap.replace('</urlset>', '  <!-- videos:start -->\n  <!-- videos:end -->\n</urlset>')
    write(sitemap_path, replace_between(sitemap, '  <!-- videos:start -->', '  <!-- videos:end -->',
                                        sitemap_entries(), sitemap_path))

    index_path = os.path.join(WEB, 'index.html')
    index = open(index_path, encoding='utf-8').read()
    links = '\n'.join(f'          <li><a href="{page_url(v)}">{esc(v["title"])}</a></li>' for v in VIDEOS)
    section = ('      <section>\n        <h2>Vídeos de Saborly</h2>\n'
               '        <p>Nuestros platos, locales, reseñas de clientes y eventos en vídeo. '
               f'<a href="{HUB_URL}">Ver todos los vídeos</a>.</p>\n        <ul>\n{links}\n        </ul>\n      </section>')
    write(index_path, replace_between(index, '      <!-- videos:start -->', '      <!-- videos:end -->', section,
                                      index_path))

    print(f'Generated {len(VIDEOS)} watch pages + hub, llms.txt, sitemap and index.html links.')


if __name__ == '__main__':
    main()
