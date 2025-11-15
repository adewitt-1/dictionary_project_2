import 'package:flutter/material.dart';
import 'services/dictionary_service.dart';
import 'models/dictionary_model.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'User Dictionary'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Future<List<Dictionary>> futureDictionary;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureDictionary = fetchDictionary('hello');
  }

  void _searchWord() {
    setState(() {
      futureDictionary = fetchDictionary(_searchController.text);
    });
  }

  Widget searchBarWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search for a word...',
        leading: const Icon(Icons.search),
        onSubmitted: (value) => _searchWord(),
      ),
    );
  }

  Padding displayDictionary(List<Dictionary> dictionary) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ListView.builder(
        // Determines how many items
          itemCount: dictionary.length,
          // Determines how to build
          itemBuilder: (BuildContext context, int position) {
            // Current dictionary object at certain index
            final word = dictionary[position];
            // Stacks widgets
            return getDefinitions(word);
          }
      ),
    );
  }

  Column getDefinitions(Dictionary word) {
    return Column(
      // .map is used to loop through each meaning of the current word
      children: word.meanings.map((meaning) {
        // Grabs each definition object through each meaning
        // and displays them on new lines for legibility
        final definitions = meaning.definitions
            .map((definition) => "⇒ ${definition.definition}")
            .join("\n\n");
        // Creates a card for each meaning
        return dictionaryCard(word, meaning, definitions);
        // Returns a list of cards (children)
      }).toList(),
    );
  }

  Card dictionaryCard(Dictionary word, Meaning meaning, String definitions) {
    return Card(
      // Styling
      color: Colors.white70,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          // Displays information on the card
          leading: const Icon(Icons.description, color: Colors.deepPurple),
          title: Column(
            // Aligns to the left
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${word.word} (${meaning.partOfSpeech})",
                style: GoogleFonts.notoSerifDisplay(
                  textStyle: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          subtitle: Text(
            definitions,
            style: GoogleFonts.oswald(
              textStyle: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          trailing: Text(
            // Displays the phonetic of the word if not null
            word.phonetic ?? (word.phonetics.isNotEmpty ? word.phonetics[0].text ?? '' : ''),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Row titleStyling() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.menu_book, size: 32, color: Colors.deepPurple),
        const SizedBox(width: 15),
        Text(
            "Welcome to the Dictionary!",
            style: GoogleFonts.dmSerifDisplay(
              textStyle: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
        ),
        const SizedBox(width: 15),
        const Icon(Icons.menu_book, size: 32, color: Colors.deepPurple),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Dictionary",
          style: GoogleFonts.dmSerifDisplay(
            textStyle: const TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          titleStyling(),
          SizedBox(height: 10),
          Text(
            "Please enter a word you'd like to look-up down below.",
            style: GoogleFonts.oswald(
              textStyle: const TextStyle(
                fontSize: 20,
                fontFamily: 'serif',
              ),
            ),
          ),
          SizedBox(height:55),
          searchBarWidget(),
          SizedBox(height: 50),
          // Allows dictionary to take up all remaining space of the screen,
          // aside from the title, search bar, and spacing.
          Expanded(
              child: FutureBuilder(
                  future: futureDictionary,
                  builder: (context, asyncSnapshot) {
                    // Error handling
                    if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }
                    if (asyncSnapshot.hasError) {
                      print('Project snapshot error: ${asyncSnapshot.error}');
                    }
                    if (asyncSnapshot.data == null ||
                        asyncSnapshot.connectionState == ConnectionState.none) {
                      print('Project snapshot data is: ${asyncSnapshot.data}');
                      return Text('No definitions were found...');
                    }

                    // Finalized data
                    List<Dictionary> dictionary = asyncSnapshot.data!;

                    // Display the dictionary. Creates scrollable list
                    return displayDictionary(dictionary);
                  }
              )
          )
        ]
      )
    );
  }
}
