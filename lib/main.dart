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

  // Variable initialization
  late Future<List<Dictionary>> futureDictionary;
  final TextEditingController _searchController = TextEditingController();

  // Initial set-up
  @override
  void initState() {
    super.initState();
    // Default value
    futureDictionary = fetchDictionary('hello');
  }

  // Searches for the word based on what was in the search bar
  void _searchWord() {
    setState(() {
      // Updates the futureDictionary variable from default "hello"
      // fetchDictionary derives from service, calling to the API
      futureDictionary = fetchDictionary(_searchController.text);
    });
  }

  // This is the widget for the search bar
  Widget searchBarWidget() {
    // Wraps it in a padding widget to add spacing
    return Padding(
      // Specifies amount of padding
      padding: const EdgeInsets.all(8.0),
      // Actual search bar function
      child: SearchBar(
        // Tracks the text entered in the search bar
        controller: _searchController,
        // Text displayed in the search bar before text is entered
        hintText: 'Search for a word...',
        // Icon
        leading: const Icon(Icons.search),
        // When pressed enter, search for the word
        onSubmitted: (value) => _searchWord(),
      ),
    );
  }

  // This will set-up the scrollable list for the dictionary results and call getDefinitions
  Widget displayDictionary(List<Dictionary> dictionary) {
    return Padding(
      // Specifies amount of padding
      padding: const EdgeInsets.all(25.0),
      // Creates scrollable list through dictionary items
      child: ListView.builder(
        // Determines how many items
          itemCount: dictionary.length,
          // Determines how to build for each item in the list
          itemBuilder: (BuildContext context, int position) {
            // Current dictionary object at certain index
            final word = dictionary[position];
            // Calls getDefinitions to create a column of definitions for the word
            return getDefinitions(word);
          }
      ),
    );
  }

  // Gets the definitions of the current word and calls dictionaryCard
  Widget getDefinitions(Dictionary word) {
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

  Widget dictionaryCard(Dictionary word, Meaning meaning, String definitions) {
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

  // Beautifies main text of the page
  Widget titleStyling() {
    return Row(
      // Aligns to the center
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icons
        const Icon(Icons.menu_book, size: 32, color: Colors.deepPurple),
        // Spacing
        const SizedBox(width: 15),
        // Text
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
        // Spacing
        const SizedBox(width: 15),
        // Icons
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
            // Waits for the "future" to arrive, which is the futureDictionary variable,
            // which is what the fetchDictionary (calls API) function returns.
            // Depending on the results, determines how to error handle or if to proceed.
            child: FutureBuilder(
                future: futureDictionary,
                builder: (context, asyncSnapshot) {
                  // Error handling
                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }
                  if (asyncSnapshot.hasError) {
                    print('Project snapshot error: ${asyncSnapshot.error}');
                    return Text('Error: ${asyncSnapshot.error}');
                  }
                  if (asyncSnapshot.data == null ||
                      asyncSnapshot.connectionState == ConnectionState.none) {
                    print('Project snapshot data is: ${asyncSnapshot.data}');
                    return Text('No definitions were found...');
                  }

                  // Finalized data
                  List<Dictionary> dictionary = asyncSnapshot.data!;

                  // Calls displayDictionary to create scrollable list for dictionary items
                  return displayDictionary(dictionary);
                }
              )
          )
        ]
      )
    );
  }
}
