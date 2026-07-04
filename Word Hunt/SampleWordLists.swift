//
//  SampleWordLists.swift
//  Word Hunt
//
//  Created by Michael Griebling on 26.06.2026.
//

import Foundation

struct SampleWordLists {
	
	static var all: [WordList] { [
		WordList(name: "Animals",
				 words: ["Albatross", "Alligator", "Badger", "Bear", "Beaver",
						 "Bison", "Camel", "Cardinal", "Cheetah", "Chimp",
						 "Cougar", "Coyote", "Crocodile", "Crow", "Deer", "Dolphin",
						 "Eagle", "Elephant", "Falcon", "Flamingo", "Fox", "Frog",
						 "Giraffe", "Gorilla", "Hawk", "Hedgehog", "Hippo",
						 "Hyena", "Iguana", "Jaguar", "Kangaroo", "Koala", "Leopard",
						 "Lion", "Lizard", "Manatee", "Moose", "Octopus", "Ostrich",
						 "Otter", "Owl", "Panda", "Panther", "Parrot", "Penguin",
						 "Porcupine", "Rabbit", "Raccoon", "Raven", "Rhino",
						 "Shark", "Sloth", "Snake", "Squirrel", "Tiger", "Turtle",
						 "Walrus", "Whale", "Wolf", "Zebra"]),
		
		WordList(name: "Birds",
				 words: ["Bluebird", "Bluejay", "Buzzard", "Canary", "Cardinal",
						 "Cassowary", "Chickadee", "Crane", "Crow", "Dove", "Eagle",
						 "Egret", "Emu", "Falcon", "Finch", "Flamingo", "Goose",
						 "Harrier", "Hawk", "Heron", "Ibis",
						 "Kestrel", "Kingfisher", "Loon", "Macaw", "Magpie",
						 "Mallard", "Merlin", "Mockingbird", "Nuthatch", "Osprey",
						 "Ostrich", "Owl", "Parrot", "Peacock", "Pelican", "Penguin",
						 "Pheasant", "Pigeon", "Puffin", "Quail", "Raven", "Roadrunner",
						 "Robin", "Rooster", "Sandpiper", "Seagull", "Sparrow",
						 "Starling", "Stork", "Swallow", "Swan", "Thrush", "Toucan",
						 "Turkey", "Vulture", "Warbler", "Woodpecker", "Wren"]),
		
		WordList(name: "Cat Breeds",
				 words: ["Abyssinian", "Aegean", "American", "Anatolian", "Asian",
						 "Australian", "Balinese", "Bambino", "Bengal", "Birman",
						 "Bobtail", "Bombay", "Burmilla", "Ceylon", "Chausie",
						 "Cheetoh", "Colorpoint", "Cornish", "Cymric", "Devon",
						 "Donskoy", "Dragon", "Egyptian", "European", "Exotic",
						 "Fold", "German", "Havana", "Highlander", "Himalayan",
						 "Japanese", "Javanese", "Korat", "LaPerm", "Lykoi",
						 "Maine", "Manx", "Minuet", "Munchkin", "Nebelung",
						 "Ocicat", "Oriental", "Owyhee", "Persian", "Peterbald",
						 "Pixie", "Ragamuffin", "Ragdoll", "Savannah", "Serengeti",
						 "Siamese", "Siberian", "Singapura", "Snowshoe", "Sokoke",
						 "Somali", "Sphynx", "Tonkinese", "Toyger", "York"]),

		WordList(name: "Colors",
				 words: ["Alabaster", "Amber", "Amethyst", "Apricot", "Aquamarine",
						 "Azure", "Beige",  "Bronze", "Burgundy", "Canary", "Celadon",
						 "Cerulean", "Charcoal", "Chartreuse", "Cobalt", "Copper",
						 "Coral", "Cream", "Crimson", "Cyan", "Ebony", "Emerald",
						 "Espresso", "Fern", "Forest", "Fuchsia", "Gold", "Indigo",
						 "Jade", "Khaki", "Lavender", "Lemon", "Lilac", "Lime",
						 "Magenta", "Maroon", "Mauve", "Mint", "Mustard", "Navy",
						 "Olive", "Onyx", "Orchid", "Peach", "Periwinkle",
						 "Plum", "Rose", "Ruby", "Rust", "Saffron", "Sage", "Salmon",
						 "Sapphire", "Scarlet", "Silver", "Tangerine", "Teal",
						 "Terracotta", "Turquoise", "Violet"]),
		
		WordList(name: "Dog Breeds",
				 words: ["Akita", "Alano", "Barbet", "Basenji", "Beagle", "Borzoi",
						 "Boxer", "Briard", "Bulldog", "Chihuahua", "Chin", "Chow",
						 "Cirneco", "Collie", "Corgi", "Dachshund", "Dalmatian",
						 "Dingo", "Doberman", "Dogo", "Elkhound", "Estrela", "Eurasier",
						 "Foxhound", "Greyhound", "Harrier", "Havanese", "Hokkaido",
						 "Husky", "Kai", "Keeshond", "Kelpie", "Komondor", "Kooikerhondje",
						 "Kuvasz", "Labrador", "Leonberger", "Lhasa", "Maltese", "Mastiff",
						 "Mudi", "Otterhound", "Papillon", "Pekingese", "Pharaoh",
						 "Pinscher", "Plott", "Pointer", "Pomeranian", "Poodle",
						 "Pug", "Puli", "Pumi", "Rafeiro", "Rottweiler", "Saluki",
						 "Samoyed", "Schipperke", "Schnauzer", "Whippet"]),
		
		WordList(name: "Flowers",
				 words: ["Allium", "Alyssum", "Anemone", "Aster", "Azalea",
						 "Begonia", "Bluebell", "Bluebonnet", "Buttercup",
						 "Calla", "Camellia", "Carnation", "Celosia",
						 "Columbine", "Coneflower",
						 "Cornflower", "Cosmos", "Crocus", "Daffodil",
						 "Dahlia", "Daisy", "Foxglove", "Freesia", "Fuchsia",
						 "Gardenia", "Geranium", "Gladiolus", "Heather",
						 "Hibiscus", "Hollyhock", "Hyacinth", "Hydrangea",
						 "Impatiens", "Iris", "Jasmine", "Lantana", "Lavender",
						 "Lilac", "Lily", "Lupine", "Magnolia", "Marigold",
						 "Nasturtium", "Orchid", "Pansy", "Peony", "Petunia",
						 "Phlox", "Poppy", "Primrose", "Ranunculus", "Rose",
						 "Snapdragon", "Sunflower", "Tulip", "Verbena", "Wisteria",
						 "Yarrow", "Zinnia"]),

		WordList(name: "Letter Codes",
				 words:	["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot",
						 "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike",
						 "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra",
						 "Tango", "Uniform", "Victor", "Whiskey", "Xray", "Yankee",
						 "Zulu"]),

		WordList(name: "Numbers",
				 words: ["One", "Two", "Three", "Four", "Five", "Six", "Seven",
						 "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen",
						 "Fifteen", "Twenty", "Thirty", "Forty", "Fifty", "Sixty",
						 "Hundred", "Thousand", "Million", "Billion", "Trillion"])
	]}
	
}
