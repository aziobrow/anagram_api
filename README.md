# Updated README

=========

# The Project
This API is intended to build a dictionary of words, defaulting to a bank of 200,000+ words comprising the entirety of the English language.  The API is set up to add and remove words from the dictionary, as well as to retrieve various permutations involving anagrams of words found within the dictionary.

This project is built with Rails::API, a PostgreSQL database, and RSpec for testing in order to demonstrate my range within the Ruby/Rails environment.

# Setup
- Clone repository
- `bundle` to install dependencies
- `rake db:setup`
- `rake db:create db:migrate`

If you'd like to run the Ibotta-provided anagram_client test suite, please do so before taking the next step to load the dictionary.  I made the choice to utilize a uniqueness validation on words in the dictionary (because after all, dictionaries don't repeat words), and the setup of the test suite will attempt to post duplicate words each time. Also for that reason, the first test of that suite is skipped, because it attempts to re-post the same words that are created in the test setup.

- If you'd like to load the default dictionary with all 200K+ words, run `rake initialize_dictionary`. Please be advised that doing so takes a significant amount of time. As an alternative, you may also choose to load a fixture file with 100 words by running `rake initialize_fixture_dictionary`.

# Special Considerations

I chose to make `Word` the underpinning model for this project in order to protect the integrity of the data. Words are case-insensitively validated (e.g., you cannot add both 'Test' and 'test' to the database), and no special characters are allowed (e.g. 'test!').  Using the `Word` model also allowed me to utilized some convenient tools for filtering, deleting, etc.

# Organization

The project is organized into two separate controllers--one to serve endpoints related to anagrams, and one to service endpoints related to words. Words are, as noted, model-backed, and anagrams are referenced through a hash with keys composed of arrays with sorted characters and values composed of the words formed by those characters

`{["a", "d", "e", "r"]=>["dear", "read"]}`

There are also three PORO services:
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
  - Supports an optional query param that indicates the maximum number of results to return.

- `GET /api/v1/anagrams/groups`
  - Endpoint that supports a query param identifying words with the most anagrams
  - Also supports a query param that will return all anagram groups of size >= *x*

- `DELETE /api/v1/anagrams/:word`
  - Endpoint to delete a word *and all of its anagrams*

-  `GET /api/v1/anagrams/verify_set`
  - Endpoint that takes a set of words and returns whether or not they are all anagrams of each other. Note that this endpoint is not limited to words in the dictionary, but is instead reliant on the words provided in the query params

# Testing

- Endpoints can be tested manually using the following curl commands (assuming the API is being served on localhost port 3000):

```{bash}
# Adding words to the corpus
$ curl -i -X POST -d '{ "words": ["read", "dear", "dare"] }' http://localhost:3000/api/v1/words.json
HTTP/1.1 201 Created
...

# Fetching anagrams
$ curl -i http://localhost:3000/api/v1/anagrams/read.json
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dear",
    "dare"
  ]
}

# Specifying maximum number of anagrams
$ curl -i http://localhost:3000/api/v1/anagrams/read.json?limit=1
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dare"
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
  anagrams: [
    "dare"
  ]
}

# Get words with most anagrams
$ curl -i http://localhost:3000/api/v1/words/group?largest=true.json
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dare"
  ]
}

# Get words with at least x number of anagrams
$ curl -i http://localhost:3000/api/v1/words/group?min_size=2.json
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dare"
  ]
}

# Get verification as to whether a set of provided words are all anagrams to each other
$ curl -i -g http://localhost:3000/api/v1/anagrams/verify_set?"words[]=read&words[]=dear&words[]=dare".json
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dare"
  ]
}

# Delete a word and all its anagrams
$ curl -i -X DELETE http://localhost:3000/api/v1/anagrams/:word.json
HTTP/1.1 204 No Content
...
```

In addition, rather than building on to the provided test suite, I chose to add my own internal test suite built in RSpec, which can be run from inside the project using `rspec`.



# Original README

Ibotta Dev Project
=========


# The Project

---

The project is to build an API that allows fast searches for [anagrams](https://en.wikipedia.org/wiki/Anagram). `dictionary.txt` is a text file containing every word in the English dictionary. Ingesting the file doesn’t need to be fast, and you can store as much data in memory as you like.

The API you design should respond on the following endpoints as specified.

- `POST /words.json`: Takes a JSON array of English-language words and adds them to the corpus (data store).
- `GET /anagrams/:word.json`:
  - Returns a JSON array of English-language words that are anagrams of the word passed in the URL.
  - This endpoint should support an optional query param that indicates the maximum number of results to return.
- `DELETE /words/:word.json`: Deletes a single word from the data store.
- `DELETE /words.json`: Deletes all contents of the data store.


**Optional**
- Endpoint that returns a count of words in the corpus and min/max/median/average word length
- Respect a query param for whether or not to include proper nouns in the list of anagrams
- Endpoint that identifies words with the most anagrams
- Endpoint that takes a set of words and returns whether or not they are all anagrams of each other
- Endpoint to return all anagram groups of size >= *x*
- Endpoint to delete a word *and all of its anagrams*

Clients will interact with the API over HTTP, and all data sent and received is expected to be in JSON format

Example (assuming the API is being served on localhost port 3000):

```{bash}
# Adding words to the corpus
$ curl -i -X POST -d '{ "words": ["read", "dear", "dare"] }' http://localhost:3000/words.json
HTTP/1.1 201 Created
...

# Fetching anagrams
$ curl -i http://localhost:3000/anagrams/read.json
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dear",
    "dare"
  ]
}

# Specifying maximum number of anagrams
$ curl -i http://localhost:3000/anagrams/read.json?limit=1
HTTP/1.1 200 OK
...
{
  anagrams: [
    "dare"
  ]
}

# Delete single word
$ curl -i -X DELETE http://localhost:3000/words/read.json
HTTP/1.1 204 No Content
...

# Delete all words
$ curl -i -X DELETE http://localhost:3000/words.json
HTTP/1.1 204 No Content
...
```

Note that a word is not considered to be its own anagram.


## Tests

We have provided a suite of tests to help as you develop the API. To run the tests you must have Ruby installed ([docs](https://www.ruby-lang.org/en/documentation/installation/)):

```{bash}
ruby anagram_test.rb
```

Only the first test will be executed, all the others have been made pending using the `pend` method. Delete or comment out the next `pend` as you get each test passing.

If you are running your server somewhere other than localhost port 3000, you can configure the test runner with configuration options described by

```{bash}
ruby anagram_test.rb -h
```

You are welcome to add additional test cases if that helps with your development process. The [benchmark-bigo](https://github.com/davy/benchmark-bigo) gem is helpful if you wish to do performance testing on your implementation.

## API Client

We have provided an API client in `anagram_client.rb`. This is used in the test suite, and can also be used in development.

To run the client in the Ruby console, use `irb`:

```{ruby}
$ irb
> require_relative 'anagram_client'
> client = AnagramClient.new
> client.post('/words.json', nil, { 'words' => ['read', 'dear', 'dare']})
> client.get('/anagrams/read.json')
```

## Documentation

Optionally, you can provide documentation that is useful to consumers and/or maintainers of the API.

Suggestions for documentation topics include:

- Features you think would be useful to add to the API
- Implementation details (which data store you used, etc.)
- Limits on the length of words that can be stored or limits on the number of results that will be returned
- Any edge cases you find while working on the project
- Design overview and trade-offs you considered


# Deliverable
---

Please provide the code for the assignment either in a private repository (GitHub or Bitbucket) or as a zip file. If you have a deliverable that is deployed on the web please provide a link, otherwise give us instructions for running it locally.
