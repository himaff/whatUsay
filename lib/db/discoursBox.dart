import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'discours.dart';

class DiscoursBox {
  static final DiscoursBox instance = DiscoursBox();
  static Box box;

  static void init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(DiscoursAdapter());
    box = await Hive.openBox("discoursBox");
    var values = box.values;
    if (values == null || values.isEmpty) {
      DiscoursBox.box.putAll(
          Map.fromIterable(discours, key: (e) => e.title.hashCode.toString(), value: (e) => e));
    }
  }

  static final List<Discours> discours = [
    Discours(
        "I have a dream",
        "i have a dream that one day this nation will rise up and live out the true meaning of its creed: we hold these truths to be self-evident, that allmen are created equal.\n i have a dream that one day on the red hills of georgia the sons offormer slaves and the sons of former slave owners will be able to sit down together at the table of brotherhood.\n i have a dream that one day even the state of mississippi, a state sweltering with the heat of injustice, sweltering with the heat of oppression, will be transformed into an oasis of freedom and justice.\n i have a dream that my four little children will one day live in a nation where they will not be judged by the color of their skin but by the content of their character.\n i have a dream today.\n i have a dream that one day down in alabama, with its vicious racists, with its governor having his lips dripping with the words of interposition and nullification - one day right there in alabama little black boys and black girls will be able to join hands with little white boys and white girls as sisters and brothers.",
        "J'ai un rêve qu'un jour cette nation se lèvera et vivra le vrai sens de son credo: nous tenons ces vérités pour évidentes, que tous les hommes sont créés égaux. \n J'ai un rêve qu'un jour sur le rouge collines de Géorgie, les fils d'anciens esclaves et les fils d'anciens propriétaires d'esclaves pourront s'asseoir ensemble à la table de la fraternité. \n Je rêve qu'un jour même l'état du Mississippi, un état étouffant par la chaleur de l'injustice , étouffante par la chaleur de l'oppression, sera transformée en une oasis de liberté et de justice. \n Je rêve que mes quatre petits enfants vivront un jour dans une nation où ils ne seront pas jugés par la couleur de leur peau mais par le contenu de leur personnage. \n J'ai un rêve aujourd'hui. \n J'ai un rêve qui un jour en Alabama, avec ses racistes vicieux, avec son gouverneur ayant les lèvres dégoulinantes des mots d'interposition et d'annulation - un jour juste là, en Alabama, lles petits garçons noirs et les filles noires pourront se joindre aux petits garçons blancs et aux filles blanches en tant que sœurs et frères.",
        "Martin Luther King"),
    Discours(
      "entree histoire",
      "during my life , I have devoted myself to this struggle of the African peoples. I fought against white domination and I fought against black domination. I cherished the ideal of a free and democratic society in which everyone lived together in harmony and with equal opportunities. It is an ideal that I hope to live for and that I hope to accomplish. But if necessary, it is an ideal for which I am ready to die.",
      "Au cours de ma vie, je me suis consacré à cette lutte des peuples africains. J'ai combattu contre la domination blanche et j'ai combattu contre la domination noire. J'ai chéri l'idéal d'une société libre et démocratique dans laquelle tout le monde vivrait ensemble en harmonie et avec des chances égales. C'est un idéal pour lequel j'espère vivre et que j'espère accomplir. Mais si nécessaire, c'est un idéal pour lequel je suis prêt à mourir.",
      "Nelson Mandela"
    )
  ];
}
