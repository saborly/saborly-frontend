"""Single source of truth for the public video pages (SEO / GEO / AEO).

Every fact here is taken from the videos themselves or their original
Instagram captions — keep it that way: search and AI engines quote this text.
Order matches lib/features/videos/data/saborly_videos.dart.
"""

SITE = 'https://saborly.es'
PUBLISHED = '2026-09-25'  # date the videos were published on saborly.es

LOCATIONS = {
    'bcn': {
        'name': 'Saborly Barcelona',
        'street': 'C/ de Pere IV, 208',
        'locality': 'Barcelona',
        'district': 'Sant Martí (Poblenou)',
        'postal': '08005',
        'phone': '+34932112072',
        'phone_display': '+34 932 11 20 72',
        'lat': 41.4036344,
        'lng': 2.1986439,
    },
    'sbd': {
        'name': 'Saborly Sabadell',
        'street': 'Av. Francesc Macià, 47',
        'locality': 'Sabadell',
        'district': None,
        'postal': '08206',
        'phone': None,
        'phone_display': None,
        'lat': None,
        'lng': None,
    },
}

TAGS = {
    'menu': ('En la carta', 'On the menu'),
    'review': ('Reseña', 'Review'),
    'event': ('Evento', 'Event'),
    'guest': ('Invitado especial', 'Special guest'),
    'experience': ('Experiencia', 'Experience'),
}

VIDEOS = [
    {
        'id': 'taste_of_pakistan',
        'slug': 'sabor-de-pakistan-en-barcelona',
        'tag': 'menu',
        'title': 'El sabor de Pakistán en Barcelona',
        'title_en': 'A taste of Pakistan in Barcelona',
        'description': 'Palitos de mozzarella que se estiran, pizza recién hecha, burgers con patatas fritas, '
                       'batidos con nata y mocktails de colores: un recorrido de once segundos por la comida '
                       'rápida de estilo paquistaní que servimos en Saborly Barcelona.',
        'points': ['Palitos de mozzarella', 'Pizza', 'Burger con patatas fritas y salsa', 'Batido con nata y caramelo',
                   'Mocktail azul y verde'],
        'en': 'Mozzarella sticks, pizza, burgers with fries, milkshakes and colourful mocktails — Pakistani-style '
              'halal fast food at Saborly in Barcelona.',
        'locations': ['bcn'],
        'keywords': ['comida paquistaní Barcelona', 'comida halal Barcelona', 'palitos de mozzarella', 'pizza halal',
                     'burger halal', 'batidos'],
    },
    {
        'id': 'friends_and_family',
        'slug': 'amigos-familia-y-buena-comida',
        'tag': 'experience',
        'title': 'Amigos, familia y buena comida',
        'title_en': 'Friends, family & great food',
        'description': 'Un paseo por Barcelona que termina en Saborly: burgers, pollo especiado recién salido de la '
                       'parrilla y mocktails para brindar. Comida rápida paquistaní para compartir con amigos y familia '
                       'en nuestro local de Pere IV.',
        'points': ['Paseo por Barcelona hasta Saborly', 'Burger con patatas', 'Pollo a la parrilla y bocados picantes',
                   'Mocktails para brindar'],
        'en': 'A walk through Barcelona that ends at Saborly: burgers, grilled spicy chicken and mocktails — halal '
              'Pakistani fast food to share with friends and family.',
        'locations': ['bcn'],
        'keywords': ['restaurante halal Barcelona', 'comer con amigos Barcelona', 'pollo a la parrilla',
                     'mocktails sin alcohol', 'Poblenou'],
    },
    {
        'id': 'great_value',
        'slug': 'bueno-bonito-y-barato',
        'tag': 'review',
        'title': 'Bueno, bonito y barato',
        'title_en': 'Good, nice & affordable',
        'description': 'Una clienta presenta Saborly como el restaurante de las «3B»: bueno, bonito y barato. Burgers '
                       'jugosas, batidos que según ella son imprescindibles, un local cuidado y comida 100 % halal a '
                       'precios económicos.',
        'points': ['Batido de galleta con nata', 'Burgers con patatas', 'Batidos “imprescindibles”',
                   'El local de Saborly y su distintivo halal'],
        'en': 'A customer calls Saborly the restaurant of the "3 Bs": good, nice and cheap — juicy burgers, must-try '
              'milkshakes and 100% halal food at budget-friendly prices.',
        'locations': ['bcn'],
        'keywords': ['restaurante barato Barcelona', 'bueno bonito y barato', 'batidos Barcelona', 'burger halal',
                     'comida halal económica'],
    },
    {
        'id': 'nauman_ijaz_visit',
        'slug': 'nauman-ijaz-visita-saborly',
        'tag': 'guest',
        'title': 'Nauman Ijaz visita Saborly',
        'title_en': 'Nauman Ijaz visits Saborly',
        'description': 'El actor paquistaní Nauman Ijaz visitó Saborly en Barcelona, probó nuestras burgers y '
                       'bebidas y elogió nuestra comida rápida de estilo paquistaní.',
        'points': ['Llegada del actor Nauman Ijaz a Saborly', 'Burger y bebida azul en la mesa',
                   'Su opinión sobre la comida de estilo paquistaní'],
        'en': 'Pakistani actor Nauman Ijaz visited Saborly in Barcelona, tried our burgers and drinks, and praised '
              'our Pakistani-style fast food.',
        'locations': ['bcn'],
        'keywords': ['Nauman Ijaz', 'Nauman Ijaz Barcelona', 'actor paquistaní', 'comida paquistaní Barcelona',
                     'Saborly'],
    },
    {
        'id': 'sabadell_fair',
        'slug': 'saborly-feria-de-sabadell',
        'tag': 'event',
        'title': 'Saborly en la Feria de Sabadell',
        'title_en': 'Saborly at the Sabadell Fair',
        'description': 'Saborly se suma a la Feria de Sabadell: «la feria está encendida y Saborly también». Ven a '
                       'probar nuestras smash burgers y pizzas 100 % halal en Saborly Sabadell, Av. Francesc '
                       'Macià, 47.',
        'points': ['Presentación desde Saborly Sabadell', 'Ambiente de la Feria de Sabadell',
                   'Smash burgers y pizzas 100 % halal'],
        'en': 'Saborly joins the Sabadell Fair — come try our 100% halal smash burgers and pizzas at Saborly '
              'Sabadell, Av. Francesc Macià 47.',
        'locations': ['sbd'],
        'keywords': ['comida halal Sabadell', 'Feria de Sabadell', 'smash burger Sabadell', 'pizza Sabadell',
                     'Saborly Sabadell'],
    },
    {
        'id': 'food_review',
        'slug': 'resena-burgers-y-pizza',
        'tag': 'review',
        'title': 'Reseña completa: burgers y pizza',
        'title_en': 'Full review: burgers & pizza',
        'description': 'Más de tres minutos de reseña sin cortes: un creador de contenido gastronómico '
                       '(#reydelacomida) prueba en Saborly una pizza en bandeja, nuestras burgers con queso, un wrap '
                       'y más, y cuenta con sinceridad qué le parece cada plato.',
        'points': ['Pizza en bandeja', 'Burgers con queso fundido', 'Wrap', 'Opinión plato a plato'],
        'en': 'A three-minute, uncut review: a food creator (#reydelacomida) tries Saborly’s pizza, cheeseburgers, '
              'a wrap and more, and gives an honest verdict on each dish.',
        'locations': ['bcn'],
        'keywords': ['reseña Saborly', 'opiniones Saborly', 'rey de la comida', 'mejor burger halal Barcelona',
                     'pizza halal Barcelona'],
    },
    {
        'id': 'family_moments',
        'slug': 'mejor-con-quien-mas-quieres',
        'tag': 'review',
        'title': 'Mejor con quien más quieres',
        'title_en': 'Better with the people you love',
        'description': 'Un día en bici por la ciudad que termina compartiendo pizza, burgers y bebidas en Saborly. '
                       'Su protagonista lo resume así: es más bonito disfrutar con la familia o los amigos, y en '
                       'Saborly el ambiente es elegante y limpio y la comida, muy sabrosa.',
        'points': ['Un día en bici por la ciudad', 'Encuentro con amigos en Saborly', 'Pizza recién cortada',
                   'Burgers y bebidas para compartir'],
        'en': 'A day riding around the city that ends sharing pizza, burgers and drinks at Saborly — “an elegant, '
              'clean place and really tasty food.”',
        'locations': ['bcn'],
        'keywords': ['restaurante para ir con amigos Barcelona', 'pizza halal', 'burger halal', 'opiniones Saborly',
                     'comida halal Barcelona'],
    },
    {
        'id': 'burger_or_pizza',
        'slug': 'burger-o-pizza',
        'tag': 'menu',
        'title': '¿Burger o pizza?',
        'title_en': 'Burger or pizza?',
        'description': '¿Con cuál te quedas? Un repaso rápido a las burgers, pizzas y wraps de Saborly para que '
                       'elijas tu favorita… o no elijas y pidas las dos.',
        'points': ['Burgers con patatas', 'Pizza', 'Wrap', 'Tú decides: ¿burger o pizza?'],
        'en': 'Burger or pizza? A quick look at Saborly’s halal burgers, pizzas and wraps — pick your favourite.',
        'locations': ['bcn', 'sbd'],
        'keywords': ['burger o pizza', 'burger halal', 'pizza halal', 'wrap', 'comida rápida halal'],
    },
    {
        'id': 'chicken_tacos',
        'slug': 'tacos-de-pollo',
        'tag': 'menu',
        'title': 'Tacos de pollo irresistibles',
        'title_en': 'Irresistible chicken tacos',
        'description': 'Tacos de pollo con queso fundido que se estira, servidos calientes en papel de aluminio. '
                       '¿Antojo de algo lleno de sabor? Ven a probarlos a Saborly.',
        'points': ['Taco de pollo', 'Queso fundido', 'Servido caliente en papel de aluminio'],
        'en': 'Chicken tacos with stretchy melted cheese, served hot in foil — halal, at Saborly.',
        'locations': ['bcn', 'sbd'],
        'keywords': ['tacos de pollo', 'tacos halal', 'tacos Barcelona', 'queso fundido', 'comida halal'],
    },
    {
        'id': 'orange_blue_mocktail',
        'slug': 'mocktail-orange-blue',
        'tag': 'menu',
        'title': 'Orange Blue Mocktail',
        'title_en': 'Orange Blue Mocktail',
        'description': 'Nuestro Orange Blue Mocktail: un cóctel sin alcohol en capas azul y verde, con hierbabuena '
                       'y mucho hielo. Refrescante, colorido y «una explosión de frescura en cada sorbo». Solo en '
                       'Saborly.',
        'points': ['Mocktail sin alcohol en capas', 'Hierbabuena fresca', 'El acompañamiento ideal para tu comida'],
        'en': 'The Orange Blue Mocktail: a layered blue-and-green alcohol-free drink with fresh mint — only at Saborly.',
        'locations': ['bcn', 'sbd'],
        'keywords': ['mocktail sin alcohol', 'bebidas sin alcohol Barcelona', 'mocktail halal', 'Orange Blue Mocktail'],
    },
    {
        'id': 'come_eat_now',
        'slug': 'ven-y-come-ahora',
        'tag': 'menu',
        'title': '¿Se te antoja algo? ¡Ven y come!',
        'title_en': 'Craving something? Come eat now!',
        'description': 'Burgers de pollo crujiente y de ternera con queso, recién hechas. Te esperamos en C/ de '
                       'Pere IV, 208 (Barcelona) y en la Av. Francesc Macià, 47 (Sabadell).',
        'points': ['Burger de pollo crujiente', 'Burger de ternera con queso', 'Nuestros dos locales'],
        'en': 'Crispy chicken burgers and beef cheeseburgers, made to order — at C/ de Pere IV 208 (Barcelona) and '
              'Av. Francesc Macià 47 (Sabadell).',
        'locations': ['bcn', 'sbd'],
        'keywords': ['burger de pollo crujiente', 'hamburguesa halal', 'burger Barcelona', 'burger Sabadell'],
    },
    {
        'id': 'red_velvet_cake',
        'slug': 'tarta-red-velvet',
        'tag': 'menu',
        'title': 'Tarta Red Velvet',
        'title_en': 'Red Velvet Cake',
        'description': 'Nuestra tarta Red Velvet: bizcocho rojo esponjoso con capas de crema. El capricho perfecto '
                       'para cualquier ocasión, ideal con un café o un té.',
        'points': ['Bizcocho Red Velvet', 'Capas de crema', 'Perfecta con café o té'],
        'en': 'Our Red Velvet Cake: soft red sponge with layers of cream — perfect with coffee or tea.',
        'locations': ['bcn', 'sbd'],
        'keywords': ['tarta red velvet', 'postres Barcelona', 'postre halal', 'red velvet cake'],
    },
]

FAQ = [
    ('¿La comida de Saborly es halal?',
     'Sí. Toda la carta de Saborly es 100 % halal: burgers, pizzas, pollo, tacos, batidos y postres.'),
    ('¿Dónde está Saborly en Barcelona?',
     'En C/ de Pere IV, 208, en el barrio de Sant Martí (Poblenou), 08005 Barcelona.'),
    ('¿Hay un Saborly en Sabadell?',
     'Sí. Saborly Sabadell está en la Av. Francesc Macià, 47, 08206 Sabadell.'),
    ('¿Qué tipo de comida sirve Saborly?',
     'Comida rápida halal de estilo paquistaní: burgers y smash burgers, pizzas, tacos de pollo, pollo frito y a '
     'la parrilla, palitos de mozzarella, patatas fritas, batidos, mocktails sin alcohol y postres como la tarta '
     'Red Velvet.'),
    ('¿Puedo pedir comida de Saborly a domicilio?',
     'Sí. Puedes pedir online en saborly.es para entrega a domicilio o para recoger en el local.'),
    ('¿Cómo contacto con Saborly?',
     'Por teléfono en el +34 932 11 20 72 o por email en info@saborly.es.'),
]
