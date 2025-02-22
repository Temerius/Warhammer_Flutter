import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ini
  Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // universes
  Future<void> seedReferenceData() async {
    await _firestore.collection('universes').doc('40k').set({
      'name': 'Warhammer 40k',
    });

    await _firestore.collection('universes').doc('fantasy').set({
      'name': 'Warhammer Fantasy',
    });

    await _firestore.collection('universes').doc('age_of_sigmar').set({
      'name': 'Age of Sigmar',
    });

    // categories
    await _firestore.collection('categories').doc('starter').set({
      'name': 'Starter Sets',
      'description': 'Sets for starting the game',
    });

    await _firestore.collection('categories').doc('expansion').set({
      'name': 'Expansions',
      'description': 'Additional sets',
    });

    await _firestore.collection('categories').doc('terrain').set({
      'name': 'Terrain',
      'description': 'Elements for creating gaming fields',
    });

    await _firestore.collection('categories').doc('single_miniatures').set({
      'name': 'Single Miniatures',
      'description': 'Miniatures for individual play or collecting',
    });

    await _firestore.collection('categories').doc('infantry_sets').set({
      'name': 'Infantry Sets',
      'description': 'Sets of infantry miniatures',
    });

    await _firestore.collection('categories').doc('vehicles').set({
      'name': 'Vehicles',
      'description': 'Miniatures of military vehicles',
    });

    await _firestore.collection('categories').doc('monsters').set({
      'name': 'Monsters',
      'description': 'Large miniatures and creatures',
    });

    // factions
    WriteBatch batch = _firestore.batch();

    batch.set(_firestore.collection('factions').doc('space_marines'), {
      'name': 'Space Marines',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('necrons'), {
      'name': 'Necrons',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('eldar'), {
      'name': 'Eldar',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('dark_eldar'), {
      'name': 'Dark Eldar',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('orks'), {
      'name': 'Orks',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('chaos'), {
      'name': 'Chaos',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('tyranids'), {
      'name': 'Tyranids',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('tau'), {
      'name': 'Tau Empire',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('adeptus_mechanicus'), {
      'name': 'Adeptus Mechanicus',
      'universeId': '40k',
    });

    batch.set(_firestore.collection('factions').doc('empire'), {
      'name': 'Empire',
      'universeId': 'fantasy',
    });

    batch.set(_firestore.collection('factions').doc('high_elves'), {
      'name': 'High Elves',
      'universeId': 'fantasy',
    });

    batch.set(_firestore.collection('factions').doc('dark_elves'), {
      'name': 'Dark Elves',
      'universeId': 'fantasy',
    });

    batch.set(_firestore.collection('factions').doc('undead'), {
      'name': 'Undead',
      'universeId': 'fantasy',
    });

    batch.set(_firestore.collection('factions').doc('dwarfs'), {
      'name': 'Dwarfs',
      'universeId': 'fantasy',
    });

    batch.set(_firestore.collection('factions').doc('greenskins'), {
      'name': 'Greenskins',
      'universeId': 'fantasy',
    });

    batch.set(_firestore.collection('factions').doc('stormcast_eternals'), {
      'name': 'Stormcast Eternals',
      'universeId': 'age_of_sigmar',
    });

    batch.set(_firestore.collection('factions').doc('seraphon'), {
      'name': 'Seraphon',
      'universeId': 'age_of_sigmar',
    });

    batch.set(_firestore.collection('factions').doc('chaos'), {
      'name': 'Chaos',
      'universeId': 'age_of_sigmar',
    });

    batch.set(_firestore.collection('factions').doc('nighthaunt'), {
      'name': 'Nighthaunt',
      'universeId': 'age_of_sigmar',
    });

    batch.set(_firestore.collection('factions').doc('ogres'), {
      'name': 'Ogres',
      'universeId': 'age_of_sigmar',
    });

    await batch.commit();
  }

  // Filling objects with WriteBatch
  Future<void> seedObjects(List<Map<String, dynamic>> objects) async {
    WriteBatch batch = _firestore.batch();

    for (var object in objects) {
      batch.set(_firestore.collection('objects').doc(object['id']), {
        'title': object['title'], // Введите заголовок
        'description': object['description'], // Введите описание
        'universe': object['universe'], // Введите вселенную
        'faction': object['faction'],
        'category': object['category'], // Введите категорию
        'price': object['price'], // Введите цену
        'releaseYear': object['releaseYear'], // Введите год выпуска
        'images': object['images'], // Введите изображения
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'comments': object['comments'],
        'averageRating': object['averageRating'],
      });
    }

    // Commit the batch
    await batch.commit();
  }

  Future<void> seedTestUser() async {
    await _firestore.collection('users').doc('test_user_1').set({
      'email': 'test@example.com',
      'displayName': 'Тестовый пользователь',
      'birthDate': DateTime(1990, 1, 1),
      'favoriteUniverse': '40k',
      'mainFaction': 'space_marines',
      'experienceLevel': 'Новичок',
      'paintingSkill': 'Начинающий',
      'bio': 'Играю с 2020 года',
      'avatarUrl': 'gs://.../avatar.jpg',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'favorites': []
    });
  }

  Future<void> run() async {
    await initialize();
    await seedReferenceData();
    await seedObjects([
      {
        'id': '1',
        'title': 'Combat Patrol: Space Marines Warhammer 40000',
        'description': """Космодесантники входят в число самых элитных воинов Империума. Созданные самим Императором из генетического материала Примархов-полубогов, они являются лучшими солдатами для жестокого и ужасного мира, в котором есть только ВОЙНА.   

      Комплектация:

      10х миниатюр Infiltrators
      1х миниатюра Impulsor
      1х миниатюра Lieutenant in Phobos Armour
      3х миниатюры Eliminators
      3х миниатюры Suppressors
      Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах. """,
        'universe': '40k',
        'faction': ['space_marines'],
        'category': 'infantry_sets',
        'price': 168.0,
        'releaseYear': 2023,
        'images': [
          'https://goodork.ru/pictures/product/big/164530_big.jpg',
          'https://goodork.ru/pictures/product/big/177370_big.jpg',
          'https://goodork.ru/pictures/product/big/177359_big.jpg',
          'https://goodork.ru/pictures/product/big/177361_big.jpg',
          'https://goodork.ru/pictures/product/big/177367_big.jpg',
          'https://goodork.ru/pictures/product/big/177360_big.jpg',
          'https://goodork.ru/pictures/product/big/126570_big.jpeg',
          'https://goodork.ru/pictures/product/big/126573_big.png',
          'https://goodork.ru/pictures/product/big/126574_big.png',
          'https://goodork.ru/pictures/product/big/126575_big.png',
          'https://goodork.ru/pictures/product/big/126576_big.png',
          'https://goodork.ru/pictures/product/big/126577_big.jpeg',
          'https://goodork.ru/pictures/product/big/126572_big.png',
          'https://goodork.ru/pictures/product/big/126571_big.png'
        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '2',
        'title': 'Warhammer 40000 Space Marines Captain In Gravis Armour',
        'description': """Капитаны — бесстрашные лидеры среди космодесантников, каждый из которых является искусным тактиком и опытным воином, вооружённым разнообразным оружием и снаряжением. Облачённый в тяжёлую гравитационную броню, капитан может бесстрашно идти в самую ожесточённую огненную бурю на поле боя. Надеть гравитационную броню — значит продемонстрировать величайшую решимость сокрушить врага, как бы глубоко он ни окопался.
На поле боя капитаны космодесанта вдохновляют подчинённых на всё более великие подвиги, а также наносят огромный урон в ближнем бою и на расстоянии.

Комплектация:

1x миниатюра Space Marines Captain In Gravis Armour
1х 40мм круглая подставка
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.    """,
        'universe': '40k',
        'faction': ['space_marines'],
        'category': 'single_miniatures',
        'price': 42.0,
        'releaseYear': 2020,
        'images': [
          'https://goodork.ru/pictures/product/big/128314_big.jpg',
          'https://goodork.ru/pictures/product/big/177333_big.jpg',
          'https://goodork.ru/pictures/product/big/177332_big.jpg',
          'https://goodork.ru/pictures/product/big/177331_big.jpg',
          'https://goodork.ru/pictures/product/big/177330_big.jpg',
          'https://goodork.ru/pictures/product/big/177328_big.jpg',
          'https://goodork.ru/pictures/product/big/177329_big.jpg'
        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '3',
        'title': 'Primaris Repulsor Executioner Warhammer 40000',
        'description': """Хотя некоторые Ордена используют «Репульсорных Палачей» в качестве бронированного сопровождения для своих специализированных танков, перевозящих войска, многие предпочитают использовать их в качестве транспорта для «Адских Бластеров» и других специализированных отрядов Примарис. В этом качестве танки с грохотом несутся по полю боя, стреляя из всех орудий. Вооружённые макроплазменными инсинераторами или тяжёлыми лазерными установками, «Палачи» обрушивают на врага шквал огня, сочетая основное вооружение с множеством вспомогательных средств.
«Репульсор-Палач» — самый хорошо вооружённый боевой танк, доступный Адептус Астартес. Он оснащён убийственно мощным основным орудием, установленным на башне, — макроплазменным сжигателем или тяжёлым лазерным деструктором, — а также соосной тяжёлой скорострельной пушкой. Добавьте к этому два гранатомёта «Крак-шторм», два штурмовых болтера, спаренный тяжёлый болтер «Икар», тяжёлый болтер «Икар», а также спаренный тяжёлый болтер, установленный на корпусе, и вашему «Репульсорному палачу» точно не будет хватать огневой мощи! Вы можете дополнить это наступательное вооружение набором оборонительных автоматических пушек и даже ракетным модулем «Икар» для дополнительной защиты с воздуха.  

       Комплектация:

1х миниатюра Primaris Repulsor Executioner
1х набор деклаей
1х круглая подставка 100 mm 
Внимание! Модель не собрана и не окрашена. Клей, краски, аксессуары и инструмент можно подобрать в соответствующих разделах.  """,
        'universe': '40k',
        'faction': ['space_marines'],
        'category': 'vehicles',
        'price': 115.0,
        'releaseYear': 2018,
        'images': [
          'https://goodork.ru/pictures/product/big/120769_big.jpg',
          'https://goodork.ru/pictures/product/big/148988_big.jpg',
          'https://goodork.ru/pictures/product/big/148989_big.jpg',
          'https://goodork.ru/pictures/product/big/148990_big.jpg',
          'https://goodork.ru/pictures/product/big/126513_big.jpeg',
          'https://goodork.ru/pictures/product/big/126515_big.png',
          'https://goodork.ru/pictures/product/big/126516_big.png',
          'https://goodork.ru/pictures/product/big/126516_big.png',
          'https://goodork.ru/pictures/product/big/126514_big.png',

        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '4',
        'title': 'Aeldari Autarch Warhammer 40000',
        'description': """Автархи славятся своим стратегическим гением, выдающимся боевым мастерством и неукротимой силой воли. Они долго шли по Пути Воина, нося ритуальные маски бесчисленных Аспектов-Воинов, но ни разу не попались в ловушку одержимости. Вместо этого эти несравненные лидеры теперь идут по Пути Командования. Овладев головокружительным разнообразием боевого снаряжения и тактик, отточенных за тысячелетия сражений, они применяют всё, чему научились, в командовании асурианскими войсками.
Из этого набора можно создать одного Автарха, которого можно персонализировать с помощью огромного количества вариантов, что позволит вам создать своего собственного лидера эльдаров в соответствии с освоенными им путями воинов-аспектов. Выбирайте между звёздным копьем и цепным мечом Скорпиона для ближнего боя, уничтожайте врагов с помощью пистолета-сюрикена, смертоносного вертуна, пусковой установки Жнеца или плазменной пушки Дракона, а также экипируйте маску Воющей Баньши и генератор прыжков Паутины. Другие варианты персонализации включают альтернативные головы, выбор туловища и знамя на рюкзаке. Эта миниатюра также полностью совместима с компонентами из набора Winged Autarch, что открывает ещё больше возможностей для комбинаций.

     Комплектация:

1 миниатюра Aeldari Autarch 
инструкция
коробка
Внимание! Модели не собраны и не окрашены. Клей, краски, аксессуары и инструмент можно подобрать в соответсвующих разделах.""",
        'universe': '40k',
        'faction': ['eldar'],
        'category': 'single_miniatures',
        'price': 32.75,
        'releaseYear': 2020,
        'images': [
          'https://goodork.ru/pictures/product/big/142954_big.jpg',
          'https://goodork.ru/pictures/product/big/142955_big.jpg',
          'https://goodork.ru/pictures/product/big/142956_big.jpg',
          'https://goodork.ru/pictures/product/big/178421_big.jpg'
          ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '5',
        'title': 'Warhammer 40,000 Starter Set',
        'description': """На обширных мирах Империума Человечества, в галактике, раздираемой варп-штормами и непрекращающимися конфликтами, армии человечества сражаются за выживание. Поскольку Империя уже стоит на грани уничтожения, флоты-ульи тиранидов появляются из холодной пустоты между звездами. Космические десантники являются последней линией обороны между этой ненасытной инопланетной угрозой и осажденными мирами Империума.
Окунитесь в 41-е тысячелетие с этим стартовым набором для Warhammer 40,000. В этой коробке вы получите увлекательный вводный опыт с невероятными моделями, игровым ковриком для сражений, полезными руководствами, а также всеми кубиками и инструментами, необходимыми для ваших первых игр. Выберите благородных космодесантников или кишащих тиранидов, передайте управление другой армией другу или члену семьи и сражайтесь с ними в течение нескольких часов развлечения. Эта коробка - отличный способ приобщиться к хобби Warhammer 40,000 – она также отлично подходит для расширения ваших существующих коллекций.

Комплектация:

1x 64-страничный справочник по стартовому набору Warhammer 40,000 в мягкой обложке
1x Капитан в доспехах терминатора
5x Терминаторы
5x Пехотинцы Инфернуса
1x Крылатый тиранид Прайм
1x Психофаг
3x Прыгуны Фон Райана
20x Термаганты
2 Стаи потрошителей
2 справочных листа – по одному для каждой армии, включая упрощенные спецификации для каждого подразделения, которые помогут обеспечить бесперебойную работу ваших игр.
1x двухсторонний игровой коврик размером 30 на 22,4 дюйма - складной бумажный игровой коврик, на каждой стороне которого изображен различный рисунок поля боя.
2 линейки
10 шестигранных кубиков 
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.  """,
        'universe': '40k',
        'faction': ['space_marines', 'tyranids'],
        'category': 'starter',
        'price': 112.0,
        'releaseYear': 2024,
        'images': [
          'https://goodork.ru/pictures/product/big/164535_big.jpg',
          'https://goodork.ru/pictures/product/big/157888_big.png',
          'https://goodork.ru/pictures/product/big/157907_big.png',
          'https://goodork.ru/pictures/product/big/157908_big.png',
          'https://goodork.ru/pictures/product/big/157905_big.png',
          'https://goodork.ru/pictures/product/big/157906_big.png',
          'https://goodork.ru/pictures/product/big/157904_big.png',
          'https://goodork.ru/pictures/product/big/157903_big.png',
          'https://goodork.ru/pictures/product/big/157901_big.png',
          'https://goodork.ru/pictures/product/big/157902_big.png',
          'https://goodork.ru/pictures/product/big/157899_big.png',
          'https://goodork.ru/pictures/product/big/157900_big.png',
          'https://goodork.ru/pictures/product/big/157897_big.png',
          'https://goodork.ru/pictures/product/big/157898_big.png',
          'https://goodork.ru/pictures/product/big/157889_big.png',
          'https://goodork.ru/pictures/product/big/157890_big.png',
          'https://goodork.ru/pictures/product/big/157895_big.png',
          'https://goodork.ru/pictures/product/big/157896_big.png'
          ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '6',
        'title': 'Skull Altar Age of Sigmar',
        'description': """Там, где последователи Кхорна сражаются, они возводят Алтари Черепов — устрашающие монументы, с которых можно воздать дань Богу Крови и получить его благословение взамен. Алтарь Черепов, поднимающийся из земли, состоит из кровавых подношений, возложенных на Трон Кхорна.
Алтарь Черепов, доступный для любой армии Кхорна без затрат на очки игры, — это фрагмент ландшафта, который делает ваших Жрецов Крови ещё сильнее. Находясь рядом с ним, они смогут перебросить свои решающие броски при молитве и вынесении приговора, что позволит вам использовать ваши любимые приговоры Кхорна или без проблем получать ключевые бонусы. В то же время находящимся поблизости волшебникам будет сложнее творить заклинания — Кхорну нет дела до тех, кто полагается на магию в своих битвах! 

      Комплектация:

1х Skull Altar      
Внимание! Модель не собрана и не окрашена. Клей, краски, аксессуары и инструмент можно подобрать в соответствующих разделах.   """,
        'universe': 'age_of_sigmar',
        'faction': ['chaos'],
        'category': 'terrain',
        'price': 52.0,
        'releaseYear': 2023,
        'images': [
          'https://goodork.ru/pictures/product/big/94644_big.jpg',
          'https://goodork.ru/pictures/product/big/180894_big.jpg',
          'https://goodork.ru/pictures/product/big/180892_big.jpg',
          'https://goodork.ru/pictures/product/big/180890_big.jpg',
          'https://goodork.ru/pictures/product/big/180891_big.jpg',
          'https://goodork.ru/pictures/product/big/105266_big.jpg'
          ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '7',
        'title': 'Necrons Illuminor Szeras Warhammer 40000',
        'description': """Иллюминор Сзерас трудится, чтобы разгадать тайны жизни, ибо он опасается, что был бы плохим богом, если бы не знал секретов жизни. Сзерас уже много веков находится на грани понимания, но почему-то окончательное постижение всегда ускользает от него. Несмотря на то, что это его навязчивая идея, его способность улучшать оружие и даже механические тела своих собратьев-некронов не имеет себе равных. Иногда таланты Зераса настолько востребованы, что он может назначить свою цену — неизменно это будет набег на планету по его выбору. Больше всего Зерас ценит эльдаров, так как они неизменно дают более интригующие результаты, чем любые другие существа в галактике. Попав в его руки, его подопытные могут рассчитывать лишь на полное боли, хотя и не обязательно короткое, существование в залитых кровью лабораторных катакомбах Зантрагоры.
Иллюминор Зерас — могущественный командир армии некронов, способный механически усиливать своих воинов, поднимая их боевую мощь на новый уровень. Он владеет древним и ужасным копьем — оружием, которое можно использовать, чтобы поражать врагов на расстоянии или в бою. 

      Комплектация:

1х миниатюра NECRONS ILLUMINOR SZERAS  
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.""",
        'universe': '40k',
        'faction': ['necrons'],
        'category': 'single_miniatures',
        'price': 49.5,
        'releaseYear': 2022,
        'images': [
          'https://goodork.ru/pictures/product/middle/165534_middle.jpg',
          'https://goodork.ru/pictures/product/big/178996_big.jpg',
          'https://goodork.ru/pictures/product/big/178994_big.jpg',
          'https://goodork.ru/pictures/product/big/125686_big.jpg',
          'https://goodork.ru/pictures/product/big/125685_big.png',

        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '8',
        'title': 'Convergence Of Dominion Warhammer 40000',
        'description': """Звёздные стелы были установлены в мирах в качестве территориальных маркеров и безмолвных стражей завистливыми некронами-аристократами. На протяжении тысячелетий они были забытыми археологическими диковинками или пугающими источниками суеверных слухов об исчезновениях и странных огнях. Теперь они снова пробуждаются, как и их хозяева.
Это укрепление, характерное для определённой фракции, не только обеспечивает прикрытие для ваших сил Некрона во время наступления, но и даёт множество преимуществ ближайшим юнитам. Каждая из трёх звёздных стел, составляющих Схождение Доминиона, оснащена межпространственным похитителем — древним оружием, идеально подходящим для уничтожения любых врагов, которые осмелятся подойти слишком близко.

      Комплектация:

3х миниатюры CONVERGENCE OF DOMINION  
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.    

""",
        'universe': '40k',
        'faction': ['necrons'],
        'category': 'terrain',
        'price': 45.2,
        'releaseYear': 2019,
        'images': [
          'https://goodork.ru/pictures/product/big/165544_big.jpg',
          'https://goodork.ru/pictures/product/big/179032_big.jpg',
          'https://goodork.ru/pictures/product/big/179029_big.jpg',
          'https://goodork.ru/pictures/product/big/179030_big.jpg',
          'https://goodork.ru/pictures/product/big/179031_big.jpg',
          'https://goodork.ru/pictures/product/big/179028_big.jpg',
          'https://goodork.ru/pictures/product/big/125701_big.jpeg',
          'https://goodork.ru/pictures/product/big/125703_big.png',

        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '9',
        'title': "Combat Patrol T'au Empire Warhammer 40000",
        'description': """Этот набор – идеальный способ начать собирать армию Империи Т'ау или пополнить уже имеющуюся. Во главе отряда опытный боец Огненный Клинок (Cadre Fireblade) и мудрый Эфирный (Ethereal). Огненный Клинок ведёт в бой Огненных Воинов (Fire Warriors) в роли ударной группы или команды прорыва, в то время как группа из практически невидимых Стелс-боескафандров XV25 (XV25 Stealth Battlesuits) и Боескафандра XV95 "Фантом" (XV95 Ghostkeel Battlesuit) обходит ряды противника, чтобы обружить на них шквальный огонь с фланга. 

Комплектация:

1x миниатюра Ethereal
1x миниатюра Cadre Fireblade
3x миниатюры Stealth Battlesuits, одна миниатюра дрона и один апгрейд-маркер Homing Beacon
10x миниатюр Fire Warriors, два дрона и башня тактической поддержки DS8
1x миниатюра XV95 Ghostkeel Battlesuit и две миниатюры дронов
набор необходимых подставок
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.    
""",
        'universe': '40k',
        'faction': ['tau'],
        'category': 'infantry_sets',
        'price': 200.0,
        'releaseYear': 2015,
        'images': [
          'https://goodork.ru/pictures/product/big/128310_big.jpg',
          'https://goodork.ru/pictures/product/big/177176_big.png',
          'https://goodork.ru/pictures/product/big/177175_big.png'

        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '10',
        'title': "Orks: Painboy Warhammer 40000",
        'description': """Дом для них там где реки крови и ужасы битвы. С нетерпением орков они латают оторванные конечности, заменяя из на пушки и когти, накладывают железные маски на изуродованные лица, а в свободное время улучшают свои прошлые изобретения. Лечилы совершенствуются своему мастерству благодаря своим обострённым инстинктам, а также старому доброму методу проб и ошибок. Лечила сопровождается компаньоном-гротом, а качестве оснащения несёт устрашающие медицинские инструменты и огромный шприц.

       Комплектация:

Пластиковые детали для сборки Painboy
1х 32мм круглая подставка
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.    """,
        'universe': '40k',
        'faction': ['orks'],
        'category': 'single_miniatures',
        'price': 29.0,
        'releaseYear': 2018,
        'images': [
          'https://goodork.ru/pictures/product/big/124408_big.jpg',
          'https://goodork.ru/pictures/product/big/179194_big.jpg',
          'https://goodork.ru/pictures/product/big/179192_big.jpg',
          'https://goodork.ru/pictures/product/big/124409_big.jpg',

        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '11',
        'title': "Orks: Rukkatrukk squigbuggy Warhammer 40000",
        'description': """Rukkatrukk Squigbuggie разъезжают по полям сражений с одной целью - уничтожения соперников. В их арсенале - Сквиги. Для разных целей и задач. Они перебрасываются ими в движении, чтобы зарядить их в Сквигометы и разобраться со всеми, кто станет на их пути.

      Комплектация:

Пластиковые детали для сборки Rukkatrukk squigbuggy
1х 150мм овальная подставка
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.    """,
        'universe': '40k',
        'faction': ['orks'],
        'category': 'vehicle',
        'price': 43.0,
        'releaseYear': 2019,
        'images': [
          'https://goodork.ru/pictures/product/big/121874_big.jpg',
          'https://goodork.ru/pictures/product/big/179165_big.jpg',
          'https://goodork.ru/pictures/product/big/179164_big.jpg',
          'https://goodork.ru/pictures/product/big/179162_big.jpg',
          'https://goodork.ru/pictures/product/big/179163_big.jpg',
          'https://goodork.ru/pictures/product/big/121875_big.jpg',
          'https://goodork.ru/pictures/product/big/121876_big.jpg',


        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '12',
        'title': "Space Marines: Brutalis Dreadnought Warhammer 40000",
        'description': """Дредноут «Бруталис» — это сокрушитель линий обороны и оружие устрашения — двуногий боевой шагоход, вооружённый для ближнего боя и управляемый павшим героем своего Ордена. Эта массивная боевая машина обрушивает шквал огня на противника, но наибольшую угрозу представляют её массивные руки. Оснащённые сокрушительными кулаками или покрытыми керамитом когтями, они могут раздавить бронированного воина, как испорченный фрукт, или пробить стену бункера, как пергамент.
Из этого набора из нескольких деталей можно собрать одного «Бруталиса Дредноута» — внушительную боевую машину, ориентированную на ближний бой. Этот мощный шагающий танк можно оснастить бронированными кулаками со встроенными болтерными винтовками или парой заострённых когтей для уничтожения брони и пехоты. На его корпусе также установлены спаренные тяжёлые болтеры «Икар» и пара орудий, закреплённых на шасси, — либо тяжёлые болтеры, либо многоствольные мелты для уничтожения танков.
Этот впечатляющий набор можно легко настроить по своему усмотрению — вы можете создать свою собственную устрашающую позу, используя шарниры в ногах, руках, талии и даже в механических пальцах. Безклеевая сборка позволяет регулировать положение лобовой брони, открывая саркофаг внутри, а также дополнительное оружие. Вы даже сможете выбрать украшения для брони.

Комплектация:

Пластиковые детали для сборки Brutalis Dreadnought
1х круглая 90-мм подставка
Внимание! Модель не собрана и не окрашена. Клей, краски и инструмент можно подобрать в соответствующих разделах.    """,
        'universe': '40k',
        'faction': ['space_marines'],
        'category': 'single_miniatures',
        'price': 79.0,
        'releaseYear': 2016,
        'images': [
          'https://goodork.ru/pictures/product/big/164632_big.jpg',
          'https://goodork.ru/pictures/product/big/162819_big.jpg',
          'https://goodork.ru/pictures/product/big/162820_big.jpg',
          'https://goodork.ru/pictures/product/big/162821_big.jpg',
          'https://goodork.ru/pictures/product/big/162822_big.jpg',
          'https://goodork.ru/pictures/product/big/162823_big.jpg',
          'https://goodork.ru/pictures/product/big/162824_big.jpg',
          'https://goodork.ru/pictures/product/big/162825_big.jpg',
        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '13',
        'title': "Predator Warhammer 40000",
        'description': """Тяжелый танк "Хищник" по праву считается основой техники Космического десанта. Созданный на основе бронетранспортера "Носорог", закалённый в неисчислимом количестве битв, он имеет мощнейшую фронтовую броню, а также усиленное башенное вооружение. Это универсальный танк, который в зависимости от комплектации может выполнять различные роли на поле боя: осуществлять огневое прикрытие других отрядов Космического десанта, уничтожать технику или пехоту противника и многое другое.

В данном наборе вы найдете все необходимые компоненты, чтобы собрать одну пластиковую модель танка "Хищник" (Space Marine Predator). В общей сложности в комплект входит 94 детали, при помощи которых можно вооружить машину на ваш вкус, любыми возможными способами, представленными в кодексе Космического десанта, в том числе: спаренной лазерной пушкой, несколькими лазерными и болтерными турелями, автопушкой, штурмовым болтером и ракетами класса “Охотник”.   

     Комплектация:

1х миниатюра (94 деталей) "Space Marines Predator
1х набор декалей 
Внимание! Модель не собрана и не окрашена. Клей, краски, аксессуары и инструмент можно подобрать в соответствующих разделах. """,
        'universe': '40k',
        'faction': ['space_marines'],
        'category': 'vehicle',
        'price': 91.0,
        'releaseYear': 2018,
        'images': [
          'https://goodork.ru/pictures/product/big/115103_big.jpg',
          'https://goodork.ru/pictures/product/big/177531_big.jpg',
          'https://goodork.ru/pictures/product/big/177530_big.jpg',
          'https://goodork.ru/pictures/product/big/126542_big.jpeg',
          'https://goodork.ru/pictures/product/big/99117_big.jpg',
          'https://goodork.ru/pictures/product/big/99118_big.jpg',
          'https://goodork.ru/pictures/product/big/99119_big.jpg',
          'https://goodork.ru/pictures/product/big/99120_big.jpg',
        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '14',
        'title': "Stormraven Gunship Warhammer 40000",
        'description': """Штурмовой корабль «Громовой ворон» — это бронированный универсальный корабль, который сочетает в себе функции десантного корабля, бронированного транспорта и ударного корабля.

Комплектация:

детали для сборки одной модели STORMRAVEN GUNSHIP с подставкой
инструкция
коробка
Внимание! Модели не собраны и не окрашены. Клей, краски, аксессуары и инструмент можно подобрать в соответсвующих разделах.""",
        'universe': '40k',
        'faction': ['space_marines'],
        'category': 'vehicle',
        'price': 95.0,
        'releaseYear': 2023,
        'images': [
          'https://goodork.ru/pictures/product/big/164542_big.jpg',
          'https://goodork.ru/pictures/product/big/177475_big.jpg',
          'https://goodork.ru/pictures/product/big/177474_big.jpg',
          'https://goodork.ru/pictures/product/big/177472_big.jpg',
          'https://goodork.ru/pictures/product/big/177473_big.jpg',
          'https://goodork.ru/pictures/product/big/126563_big.jpeg',
          'https://goodork.ru/pictures/product/big/126564_big.png',
          'https://goodork.ru/pictures/product/big/126565_big.png',
          'https://goodork.ru/pictures/product/big/126566_big.png',
          'https://goodork.ru/pictures/product/big/126567_big.png'
        ],
        'comments': [],
        'averageRating': 0.0,
      },
      {
        'id': '15',
        'title': "Warhammer 40000 Starter Command Edition",
        'description': """Начните играть в Warhammer 40,000 с изданием Command Edition – набором, разработанным для того, чтобы дать вам полное представление о лучшей в мире научно-фантастической военной игре. С моделями, правилами, руководствами, которые помогут вам начать и многим другим, этот массивный набор избавит вас от хлопот, связанных с началом вашего хобби.
Внимание! Модели не собраны и не окрашены. Клей, краски и инструмент можно подобрать в соответствующих разделах.    

Комплектация:

1х миниатюра Primaris Captain
3х миниатюры Outriders
5х миниатюр Assault Intercessors
 
1х миниатюра Necron Overlord
10х миниатюр Necron Warriors
3х миниатюр Canoptek Scarab Swarms
3х миниатюры Skorpekh Destroyers
 
детали для сборки игрового ландшафта
1х книга правил в мягкой обложке (184 стр.) на русском языке
1х буклет с правилами и художественным описанием враждующих сторон
1х инструкция по сборке миниатюр
1х лист с декалями Space Marines
8х кубиков Д6
2х игровые линейки
бумажное игровое поле
картонный элемент ландшафта
все необходимые подставки для миниатюр набора""",
        'universe': '40k',
        'faction': ['space_marines', 'necrons'],
        'category': 'starter',
        'price': 315.0,
        'releaseYear': 2020,
        'images': [
          'https://goodork.ru/pictures/product/big/164533_big.jpg',
          'https://goodork.ru/pictures/product/big/110279_big.jpg',
          'https://goodork.ru/pictures/product/big/125715_big.jpeg',
          'https://goodork.ru/pictures/product/big/125714_big.jpeg',
          'https://goodork.ru/pictures/product/big/125716_big.png',
          'https://goodork.ru/pictures/product/big/125717_big.png',
          'https://goodork.ru/pictures/product/big/125718_big.png',
          'https://goodork.ru/pictures/product/big/125719_big.png',
          'https://goodork.ru/pictures/product/big/125720_big.png',
          'https://goodork.ru/pictures/product/big/125721_big.png',
          'https://goodork.ru/pictures/product/big/125722_big.png',
          'https://goodork.ru/pictures/product/big/125723_big.png',
          'https://goodork.ru/pictures/product/big/125724_big.png',
          'https://goodork.ru/pictures/product/big/125725_big.png'
        ],
        'comments': [],
        'averageRating': 0.0,
      },
    ]);
    await seedTestUser();
    print('Firestore заполнен данными!');
  }
}