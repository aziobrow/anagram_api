
# Updated README

=========

# The Project
This API is intended to build a dictionary of words, defaulting to a bank of 200,000+ words comprising the entirety of the English language.  The API is set up to add and remove words from the dictionary, as well as to retrieve various permutations involving anagrams of words found within the dictionary.

This project is built with Rails::API, a PostgreSQL database, and RSpec for testing in order to demonstrate my range within the Ruby/Rails environment.

All optional endpoints have been implemented, although query param to exclude proper nouns is limited in the sense that it must be the only query param and only works on the `/api/v1/anagrams/:word` route, simply because of time constraints.  Given more time, I'd like to expand this to work on all anagram routes and with multiple query params.

Logic was implemented with the most efficient code that occurred to me while writing it. I expect that there's plenty of room for refactoring, especially as time became short, but if it gets to code review, I'd love feedback on those points. As a note, I also took a few liberties as I was building the API. For example, after POSTing a new word, I opted to return either the word objects that were created or the errors for each word that failed, rather than the 201 that was originally documented.  I also decided to use versioned routes.  I wanted to add more elegant error handling to the delete to notify the user if there were any errors in deletion, but didn't quite get there.

For context, I began this project on Saturday, June 30th and finished on Wednesday, July 4th.  

# Setup
- Clone repository
- `bundle` to install dependencies
- `rake db:setup`
- `rake db:create db:migrate`

If you'd like to run the Ibotta-provided anagram_client test suite, please do so before taking the next step to load the dictionary.  I made the choice to utilize a uniqueness validation on words in the dictionary (because after all, dictionaries don't repeat words), and the setup of the test suite will attempt to post duplicate words each time. Also for that reason, the first test of that suite is skipped, because it attempts to recreate the same words that are created in the test setup.

- If you'd like to load the default dictionary with all 200K+ words, run `rake initialize_dictionary`. Please be advised that doing so requires a significant amount of time. As an alternative, you may also choose to load a fixture file with 50 words by running `rake initialize_fixture_dictionary`.

- `rails s`

# Special Considerations

I chose to make `Word` the backing model for this project in order to protect the integrity of the data. Words are case-insensitively validated (e.g., you cannot add both 'Test' and 'test' to the database), and no special characters are allowed (e.g. 'test!'). Whitespace is also not supported at this time (e.g., 'this test'), although that might be an interesting feature for anagrams in the future. Using the `Word` model also allowed me to utilize some convenient tools for filtering, deleting, etc.

# Organization

The project is organized into two separate controllers--one to serve endpoints related to anagrams, and one to service endpoints related to words. Words are, as noted, model-backed, and anagrams are referenced through a hash with keys composed of arrays with sorted characters and values composed of the words formed by those characters

`{["a", "d", "e", "r"]=>["dear", "read"]}`

There are also three PORO services, largely intended to encapsulate logic and clean up the controllers:
- AnagramHandler: navigates the aforementioned hash to return desired output to the controller
- DictionaryBuilder: converts a text file into rows of words in the database.  This could have been done in the seed file, but I was considering what might be more broadly useful in terms of flexibility.
- WordsCreator: handles the work of creating words. I chose this route because of the nature of the requirements for creating new words, which implied batch posting.  I wanted to ensure that 1) a user couldn't post partial data, and 2) rather than returning a generic 400 response in which the user would be unsure as to what failed and why, I wanted to notify the user about the specific word/s that failed as well as the associated errors.

# Endpoints

The following endpoints are supported:

- `POST /api/v1/words.json`
  - Takes a JSON array of English-language words and adds them to the corpus

- `DELETE /api/v1/words/:word.json`
  - Deletes a single word from the data store.

- `DELETE /api/v1/words.json`
  - Deletes all contents of the data store.

- `GET /api/v1/words/analytics.json`
  - Endpoint that returns a count of words in the corpus and min/max/median/average word length


- `GET /api/v1/anagrams/:word.json`
  - Returns a JSON array of English-language words that are anagrams of the word passed in the URL
  - Supports an optional query param that indicates the maximum number of results to return
  - Also supports an optional query param to exclude proper nouns from the results

- `GET /api/v1/anagrams/top_results`
  - Returns the words that have the most anagrams (e.g., the largest anagram group)
  - Supports an optional query param that will return all anagram groups of size >= *x*

- `DELETE /api/v1/anagrams/:word`
  - Endpoint to delete a word *and all of its anagrams*

-  `GET /api/v1/anagrams/verify_set`
  - Endpoint that takes a set of words and returns whether or not they are all anagrams of each other. Note that this endpoint is not limited to words in the dictionary, but is instead reliant on the words provided in the query params

# Testing

- Endpoints can be tested manually using the following curl commands (assuming the API is being served on localhost port 3000):

```{bash}
# Adding words to the corpus
$ curl -i -X POST -d '{ "words": ["read", "Dear", "dare"] }' http://localhost:3000/api/v1/words.json
HTTP/1.1 201  Created
...
[
  {
    id: 31507,
    word: "read",
    created_at: 2018-07-05T02:49:38.513Z,
    updated_at: 2018-07-05T02:49:38.513Z
  },
  {
    id: 31508,
    word: "Dear",
    created_at: 2018-07-05T02:49:38.527Z,
    updated_at: 2018-07-05T02:49:38.527Z
  },
  {
    id: 31509,
    word: dare,
    created_at: 2018-07-05T02:49:38.535Z,
    updated_at: 2018-07-05T02:49:38.535Z
  }
]

# Fetching anagrams
$ curl -i http://localhost:3000/api/v1/anagrams/read.json
HTTP/1.1 200 OK
...
{
  anagrams: [
    "Dear",
    "dare"
  ]
}

# Excluding proper nouns from results
$ curl -i http://localhost:3000/api/v1/anagrams/read.json?proper_nouns=false
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dare"
  ]
}

# Specifying maximum number of anagrams
$ curl -i http://localhost:3000/api/v1/anagrams/read.json?limit=1
HTTP/1.1 200 OK
...
{
  anagrams: [
    "Dear"
  ]
}

# Delete single word
$ curl -i -X DELETE http://localhost:3000/api/v1/words/read.json
HTTP/1.1 204 No Content
...

# Delete all words
$ curl -i -X DELETE http://localhost:3000/api/v1/words.json
HTTP/1.1 204 No Content
...

# Get word analytics
$ curl -i http://localhost:3000/api/v1/words/analytics.json
HTTP/1.1 200 OK
...
{
  analytics: {
    total_words: 3,
    word_length: {
      minimum: 4,
      maximum: 4,
      median: 4.0,
      average: 4.0
    }
  }
}

# Get words with most anagrams (top anagram group)
$ curl -i http://localhost:3000/api/v1/anagrams/top_results.json
HTTP/1.1 200 OK
...
{
  top_results: [
    ["read", "Dear", "dare"]
  ]
}

# Get anagram groups of size greater than or equal to x
$ curl -i http://localhost:3000/api/v1/anagrams/top_results.json?min_size=2
HTTP/1.1 200 OK
...
{
  top_results: [
    ["read", "Dear", "dare"],
    ["on", "no"]
  ]
}

# Get verification as to whether a set of provided words are all anagrams to each other
$ curl -i -g http://localhost:3000/api/v1/anagrams/verify_set.json?"words[]=read&words[]=dear&words[]=dare"
HTTP/1.1 200 OK
...
{
  anagrams?:
    true
}

# Delete a word and all its anagrams
$ curl -i -X DELETE http://localhost:3000/api/v1/anagrams/read.json
HTTP/1.1 204 No Content
...
```

In addition, rather than building on to the provided test suite, I chose to add my own internal test suite built in RSpec, which can be run from inside the project using `rspec`.
