// 由官方原始 GBFS v2.3 Schema 文件生成；文件本身保持原样。

///|
let schema_v23_gbfs : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#gbfsjson",
  #|  "description":
  #|    "Auto-discovery file that links to all of the other files published by the system.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Response data in the form of name:value pairs.",
  #|      "type": "object",
  #|      "patternProperties": {
  #|        "^[a-z]{2,3}(-[A-Z]{2})?$": {
  #|          "type": "object",
  #|          "properties": {
  #|            "feeds": {
  #|              "description":
  #|                "An array of all of the feeds that are published by the auto-discovery file. Each element in the array is an object with the keys below.",
  #|              "type": "array",
  #|              "items": {
  #|                "type": "object",
  #|                "properties": {
  #|                  "name": {
  #|                    "description":
  #|                      "Key identifying the type of feed this is. The key must be the base file name defined in the spec for the corresponding feed type.",
  #|                    "type": "string",
  #|                    "enum": [
  #|                      "gbfs",
  #|                      "gbfs_versions",
  #|                      "system_information",
  #|                      "vehicle_types",
  #|                      "station_information",
  #|                      "station_status",
  #|                      "free_bike_status",
  #|                      "system_hours",
  #|                      "system_alerts",
  #|                      "system_calendar",
  #|                      "system_regions",
  #|                      "system_pricing_plans",
  #|                      "geofencing_zones"
  #|                    ]
  #|                  },
  #|                  "url": {
  #|                    "description": "URL for the feed.",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  }
  #|                },
  #|                "required": ["name", "url"]
  #|              },
  #|              "minItems": 1,
  #|              "contains": {
  #|                "properties": {
  #|                  "name": { "const": "system_information" }
  #|                }
  #|              },
  #|              "allOf": [
  #|                {
  #|                  "anyOf": [
  #|                    {
  #|                      "contains": {
  #|                        "properties": {
  #|                          "name": { "const": "station_status" }
  #|                        }
  #|                      }
  #|                    },
  #|                    {
  #|                      "contains": {
  #|                        "properties": {
  #|                          "name": { "const": "free_bike_status" }
  #|                        }
  #|                      }
  #|                    }
  #|                  ]
  #|                },
  #|                {
  #|                  "if": {
  #|                    "contains": {
  #|                      "properties": {
  #|                        "name": { "const": "station_information" }
  #|                      }
  #|                    }
  #|                  },
  #|                  "then": {
  #|                    "contains": {
  #|                      "properties": {
  #|                        "name": { "const": "station_status" }
  #|                      }
  #|                    }
  #|                  }
  #|                }
  #|              ]
  #|            }
  #|          },
  #|          "required": ["feeds"]
  #|        }
  #|      },
  #|      "minProperties": 1,
  #|      "additionalProperties": false
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_gbfs_versions : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#gbfs_versionsjson",
  #|  "description":
  #|    "Lists all feed endpoints published according to version sof the GBFS documentation. (added in v1.1)",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework.",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Response data in the form of name:value pairs.",
  #|      "type": "object",
  #|      "properties": {
  #|        "versions": {
  #|          "description":
  #|            "Contains one object, as defined below, for each of the available versions of a feed. The array must be sorted by increasing MAJOR and MINOR version number.",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "version": {
  #|                "description":
  #|                  "The semantic version of the feed in the form X.Y",
  #|                "type": "string",
  #|                "enum": [
  #|                  "1.0",
  #|                  "1.1",
  #|                  "2.0",
  #|                  "2.1",
  #|                  "2.2",
  #|                  "2.3",
  #|                  "3.0"
  #|                ]
  #|              },
  #|              "url": {
  #|                "description": "URL of the corresponding gbfs.json endpoint",
  #|                "type": "string",
  #|                "format": "uri"
  #|              }
  #|            },
  #|            "required": ["version", "url"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["versions"],
  #|      "additionalProperties": false
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_system_information : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#system_informationjson",
  #|  "description":
  #|    "Details including system operator, system location, year implemented, URL, contact info, time zone.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Response data in the form of name:value pairs.",
  #|      "type": "object",
  #|      "properties": {
  #|        "system_id": {
  #|          "description":
  #|            "Identifier for this vehicle share system. This should be globally unique (even between different systems).",
  #|          "type": "string"
  #|        },
  #|        "language": {
  #|          "description":
  #|            "The language that will be used throughout the rest of the files. It must match the value in the gbfs.json file.",
  #|          "type": "string",
  #|          "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|        },
  #|        "name": {
  #|          "description": "Name of the system to be displayed to customers.",
  #|          "type": "string"
  #|        },
  #|        "short_name": {
  #|          "description": "Optional abbreviation for a system.",
  #|          "type": "string"
  #|        },
  #|        "operator": {
  #|          "description": "Name of the operator",
  #|          "type": "string"
  #|        },
  #|        "url": {
  #|          "description": "The URL of the vehicle share system.",
  #|          "type": "string",
  #|          "format": "uri"
  #|        },
  #|        "purchase_url": {
  #|          "description": "URL where a customer can purchase a membership.",
  #|          "type": "string",
  #|          "format": "uri"
  #|        },
  #|        "start_date": {
  #|          "description": "Date that the system began operations.",
  #|          "type": "string",
  #|          "format": "date"
  #|        },
  #|        "phone_number": {
  #|          "description":
  #|            "A single voice telephone number for the specified system that presents the telephone number as typical for the system's service area.",
  #|          "type": "string"
  #|        },
  #|        "email": {
  #|          "description":
  #|            "Email address actively monitored by the operator's customer service department.",
  #|          "type": "string",
  #|          "format": "email"
  #|        },
  #|        "feed_contact_email": {
  #|          "description":
  #|            "A single contact email address for consumers of this feed to report technical issues (added in v1.1).",
  #|          "type": "string",
  #|          "format": "email"
  #|        },
  #|        "timezone": {
  #|          "description": "The time zone where the system is located.",
  #|          "type": "string",
  #|          "enum": [
  #|            "Africa/Abidjan",
  #|            "Africa/Accra",
  #|            "Africa/Addis_Ababa",
  #|            "Africa/Algiers",
  #|            "Africa/Asmara",
  #|            "Africa/Asmera",
  #|            "Africa/Bamako",
  #|            "Africa/Bangui",
  #|            "Africa/Banjul",
  #|            "Africa/Bissau",
  #|            "Africa/Blantyre",
  #|            "Africa/Brazzaville",
  #|            "Africa/Bujumbura",
  #|            "Africa/Cairo",
  #|            "Africa/Casablanca",
  #|            "Africa/Ceuta",
  #|            "Africa/Conakry",
  #|            "Africa/Dakar",
  #|            "Africa/Dar_es_Salaam",
  #|            "Africa/Djibouti",
  #|            "Africa/Douala",
  #|            "Africa/El_Aaiun",
  #|            "Africa/Freetown",
  #|            "Africa/Gaborone",
  #|            "Africa/Harare",
  #|            "Africa/Johannesburg",
  #|            "Africa/Juba",
  #|            "Africa/Kampala",
  #|            "Africa/Khartoum",
  #|            "Africa/Kigali",
  #|            "Africa/Kinshasa",
  #|            "Africa/Lagos",
  #|            "Africa/Libreville",
  #|            "Africa/Lome",
  #|            "Africa/Luanda",
  #|            "Africa/Lubumbashi",
  #|            "Africa/Lusaka",
  #|            "Africa/Malabo",
  #|            "Africa/Maputo",
  #|            "Africa/Maseru",
  #|            "Africa/Mbabane",
  #|            "Africa/Mogadishu",
  #|            "Africa/Monrovia",
  #|            "Africa/Nairobi",
  #|            "Africa/Ndjamena",
  #|            "Africa/Niamey",
  #|            "Africa/Nouakchott",
  #|            "Africa/Ouagadougou",
  #|            "Africa/Porto-Novo",
  #|            "Africa/Sao_Tome",
  #|            "Africa/Timbuktu",
  #|            "Africa/Tripoli",
  #|            "Africa/Tunis",
  #|            "Africa/Windhoek",
  #|            "America/Adak",
  #|            "America/Anchorage",
  #|            "America/Anguilla",
  #|            "America/Antigua",
  #|            "America/Araguaina",
  #|            "America/Argentina/Buenos_Aires",
  #|            "America/Argentina/Catamarca",
  #|            "America/Argentina/ComodRivadavia",
  #|            "America/Argentina/Cordoba",
  #|            "America/Argentina/Jujuy",
  #|            "America/Argentina/La_Rioja",
  #|            "America/Argentina/Mendoza",
  #|            "America/Argentina/Rio_Gallegos",
  #|            "America/Argentina/Salta",
  #|            "America/Argentina/San_Juan",
  #|            "America/Argentina/San_Luis",
  #|            "America/Argentina/Tucuman",
  #|            "America/Argentina/Ushuaia",
  #|            "America/Aruba",
  #|            "America/Asuncion",
  #|            "America/Atikokan",
  #|            "America/Atka",
  #|            "America/Bahia",
  #|            "America/Bahia_Banderas",
  #|            "America/Barbados",
  #|            "America/Belem",
  #|            "America/Belize",
  #|            "America/Blanc-Sablon",
  #|            "America/Boa_Vista",
  #|            "America/Bogota",
  #|            "America/Boise",
  #|            "America/Buenos_Aires",
  #|            "America/Cambridge_Bay",
  #|            "America/Campo_Grande",
  #|            "America/Cancun",
  #|            "America/Caracas",
  #|            "America/Catamarca",
  #|            "America/Cayenne",
  #|            "America/Cayman",
  #|            "America/Chicago",
  #|            "America/Chihuahua",
  #|            "America/Ciudad_Juarez",
  #|            "America/Coral_Harbour",
  #|            "America/Cordoba",
  #|            "America/Costa_Rica",
  #|            "America/Creston",
  #|            "America/Cuiaba",
  #|            "America/Curacao",
  #|            "America/Danmarkshavn",
  #|            "America/Dawson",
  #|            "America/Dawson_Creek",
  #|            "America/Denver",
  #|            "America/Detroit",
  #|            "America/Dominica",
  #|            "America/Edmonton",
  #|            "America/Eirunepe",
  #|            "America/El_Salvador",
  #|            "America/Ensenada",
  #|            "America/Fort_Nelson",
  #|            "America/Fort_Wayne",
  #|            "America/Fortaleza",
  #|            "America/Glace_Bay",
  #|            "America/Godthab",
  #|            "America/Goose_Bay",
  #|            "America/Grand_Turk",
  #|            "America/Grenada",
  #|            "America/Guadeloupe",
  #|            "America/Guatemala",
  #|            "America/Guayaquil",
  #|            "America/Guyana",
  #|            "America/Halifax",
  #|            "America/Havana",
  #|            "America/Hermosillo",
  #|            "America/Indiana/Indianapolis",
  #|            "America/Indiana/Knox",
  #|            "America/Indiana/Marengo",
  #|            "America/Indiana/Petersburg",
  #|            "America/Indiana/Tell_City",
  #|            "America/Indiana/Vevay",
  #|            "America/Indiana/Vincennes",
  #|            "America/Indiana/Winamac",
  #|            "America/Indianapolis",
  #|            "America/Inuvik",
  #|            "America/Iqaluit",
  #|            "America/Jamaica",
  #|            "America/Jujuy",
  #|            "America/Juneau",
  #|            "America/Kentucky/Louisville",
  #|            "America/Kentucky/Monticello",
  #|            "America/Knox_IN",
  #|            "America/Kralendijk",
  #|            "America/La_Paz",
  #|            "America/Lima",
  #|            "America/Los_Angeles",
  #|            "America/Louisville",
  #|            "America/Lower_Princes",
  #|            "America/Maceio",
  #|            "America/Managua",
  #|            "America/Manaus",
  #|            "America/Marigot",
  #|            "America/Martinique",
  #|            "America/Matamoros",
  #|            "America/Mazatlan",
  #|            "America/Mendoza",
  #|            "America/Menominee",
  #|            "America/Merida",
  #|            "America/Metlakatla",
  #|            "America/Mexico_City",
  #|            "America/Miquelon",
  #|            "America/Moncton",
  #|            "America/Monterrey",
  #|            "America/Montevideo",
  #|            "America/Montreal",
  #|            "America/Montserrat",
  #|            "America/Nassau",
  #|            "America/New_York",
  #|            "America/Nipigon",
  #|            "America/Nome",
  #|            "America/Noronha",
  #|            "America/North_Dakota/Beulah",
  #|            "America/North_Dakota/Center",
  #|            "America/North_Dakota/New_Salem",
  #|            "America/Nuuk",
  #|            "America/Ojinaga",
  #|            "America/Panama",
  #|            "America/Pangnirtung",
  #|            "America/Paramaribo",
  #|            "America/Phoenix",
  #|            "America/Port-au-Prince",
  #|            "America/Port_of_Spain",
  #|            "America/Porto_Acre",
  #|            "America/Porto_Velho",
  #|            "America/Puerto_Rico",
  #|            "America/Punta_Arenas",
  #|            "America/Rainy_River",
  #|            "America/Rankin_Inlet",
  #|            "America/Recife",
  #|            "America/Regina",
  #|            "America/Resolute",
  #|            "America/Rio_Branco",
  #|            "America/Rosario",
  #|            "America/Santa_Isabel",
  #|            "America/Santarem",
  #|            "America/Santiago",
  #|            "America/Santo_Domingo",
  #|            "America/Sao_Paulo",
  #|            "America/Scoresbysund",
  #|            "America/Shiprock",
  #|            "America/Sitka",
  #|            "America/St_Barthelemy",
  #|            "America/St_Johns",
  #|            "America/St_Kitts",
  #|            "America/St_Lucia",
  #|            "America/St_Thomas",
  #|            "America/St_Vincent",
  #|            "America/Swift_Current",
  #|            "America/Tegucigalpa",
  #|            "America/Thule",
  #|            "America/Thunder_Bay",
  #|            "America/Tijuana",
  #|            "America/Toronto",
  #|            "America/Tortola",
  #|            "America/Vancouver",
  #|            "America/Virgin",
  #|            "America/Whitehorse",
  #|            "America/Winnipeg",
  #|            "America/Yakutat",
  #|            "America/Yellowknife",
  #|            "Antarctica/Casey",
  #|            "Antarctica/Davis",
  #|            "Antarctica/DumontDUrville",
  #|            "Antarctica/Macquarie",
  #|            "Antarctica/Mawson",
  #|            "Antarctica/McMurdo",
  #|            "Antarctica/Palmer",
  #|            "Antarctica/Rothera",
  #|            "Antarctica/South_Pole",
  #|            "Antarctica/Syowa",
  #|            "Antarctica/Troll",
  #|            "Antarctica/Vostok",
  #|            "Arctic/Longyearbyen",
  #|            "Asia/Aden",
  #|            "Asia/Almaty",
  #|            "Asia/Amman",
  #|            "Asia/Anadyr",
  #|            "Asia/Aqtau",
  #|            "Asia/Aqtobe",
  #|            "Asia/Ashgabat",
  #|            "Asia/Ashkhabad",
  #|            "Asia/Atyrau",
  #|            "Asia/Baghdad",
  #|            "Asia/Bahrain",
  #|            "Asia/Baku",
  #|            "Asia/Bangkok",
  #|            "Asia/Barnaul",
  #|            "Asia/Beirut",
  #|            "Asia/Bishkek",
  #|            "Asia/Brunei",
  #|            "Asia/Calcutta",
  #|            "Asia/Chita",
  #|            "Asia/Choibalsan",
  #|            "Asia/Chongqing",
  #|            "Asia/Chungking",
  #|            "Asia/Colombo",
  #|            "Asia/Dacca",
  #|            "Asia/Damascus",
  #|            "Asia/Dhaka",
  #|            "Asia/Dili",
  #|            "Asia/Dubai",
  #|            "Asia/Dushanbe",
  #|            "Asia/Famagusta",
  #|            "Asia/Gaza",
  #|            "Asia/Harbin",
  #|            "Asia/Hebron",
  #|            "Asia/Ho_Chi_Minh",
  #|            "Asia/Hong_Kong",
  #|            "Asia/Hovd",
  #|            "Asia/Irkutsk",
  #|            "Asia/Istanbul",
  #|            "Asia/Jakarta",
  #|            "Asia/Jayapura",
  #|            "Asia/Jerusalem",
  #|            "Asia/Kabul",
  #|            "Asia/Kamchatka",
  #|            "Asia/Karachi",
  #|            "Asia/Kashgar",
  #|            "Asia/Kathmandu",
  #|            "Asia/Katmandu",
  #|            "Asia/Khandyga",
  #|            "Asia/Kolkata",
  #|            "Asia/Krasnoyarsk",
  #|            "Asia/Kuala_Lumpur",
  #|            "Asia/Kuching",
  #|            "Asia/Kuwait",
  #|            "Asia/Macao",
  #|            "Asia/Macau",
  #|            "Asia/Magadan",
  #|            "Asia/Makassar",
  #|            "Asia/Manila",
  #|            "Asia/Muscat",
  #|            "Asia/Nicosia",
  #|            "Asia/Novokuznetsk",
  #|            "Asia/Novosibirsk",
  #|            "Asia/Omsk",
  #|            "Asia/Oral",
  #|            "Asia/Phnom_Penh",
  #|            "Asia/Pontianak",
  #|            "Asia/Pyongyang",
  #|            "Asia/Qatar",
  #|            "Asia/Qostanay",
  #|            "Asia/Qyzylorda",
  #|            "Asia/Rangoon",
  #|            "Asia/Riyadh",
  #|            "Asia/Saigon",
  #|            "Asia/Sakhalin",
  #|            "Asia/Samarkand",
  #|            "Asia/Seoul",
  #|            "Asia/Shanghai",
  #|            "Asia/Singapore",
  #|            "Asia/Srednekolymsk",
  #|            "Asia/Taipei",
  #|            "Asia/Tashkent",
  #|            "Asia/Tbilisi",
  #|            "Asia/Tehran",
  #|            "Asia/Tel_Aviv",
  #|            "Asia/Thimbu",
  #|            "Asia/Thimphu",
  #|            "Asia/Tokyo",
  #|            "Asia/Tomsk",
  #|            "Asia/Ujung_Pandang",
  #|            "Asia/Ulaanbaatar",
  #|            "Asia/Ulan_Bator",
  #|            "Asia/Urumqi",
  #|            "Asia/Ust-Nera",
  #|            "Asia/Vientiane",
  #|            "Asia/Vladivostok",
  #|            "Asia/Yakutsk",
  #|            "Asia/Yangon",
  #|            "Asia/Yekaterinburg",
  #|            "Asia/Yerevan",
  #|            "Atlantic/Azores",
  #|            "Atlantic/Bermuda",
  #|            "Atlantic/Canary",
  #|            "Atlantic/Cape_Verde",
  #|            "Atlantic/Faeroe",
  #|            "Atlantic/Faroe",
  #|            "Atlantic/Jan_Mayen",
  #|            "Atlantic/Madeira",
  #|            "Atlantic/Reykjavik",
  #|            "Atlantic/South_Georgia",
  #|            "Atlantic/St_Helena",
  #|            "Atlantic/Stanley",
  #|            "Australia/ACT",
  #|            "Australia/Adelaide",
  #|            "Australia/Brisbane",
  #|            "Australia/Broken_Hill",
  #|            "Australia/Canberra",
  #|            "Australia/Currie",
  #|            "Australia/Darwin",
  #|            "Australia/Eucla",
  #|            "Australia/Hobart",
  #|            "Australia/LHI",
  #|            "Australia/Lindeman",
  #|            "Australia/Lord_Howe",
  #|            "Australia/Melbourne",
  #|            "Australia/North",
  #|            "Australia/NSW",
  #|            "Australia/Perth",
  #|            "Australia/Queensland",
  #|            "Australia/South",
  #|            "Australia/Sydney",
  #|            "Australia/Tasmania",
  #|            "Australia/Victoria",
  #|            "Australia/West",
  #|            "Australia/Yancowinna",
  #|            "Brazil/Acre",
  #|            "Brazil/DeNoronha",
  #|            "Brazil/East",
  #|            "Brazil/West",
  #|            "Canada/Atlantic",
  #|            "Canada/Central",
  #|            "Canada/Eastern",
  #|            "Canada/Mountain",
  #|            "Canada/Newfoundland",
  #|            "Canada/Pacific",
  #|            "Canada/Saskatchewan",
  #|            "Canada/Yukon",
  #|            "CET",
  #|            "Chile/Continental",
  #|            "Chile/EasterIsland",
  #|            "CST6CDT",
  #|            "Cuba",
  #|            "EET",
  #|            "Egypt",
  #|            "Eire",
  #|            "EST",
  #|            "EST5EDT",
  #|            "Etc/GMT",
  #|            "Etc/GMT+0",
  #|            "Etc/GMT+1",
  #|            "Etc/GMT+10",
  #|            "Etc/GMT+11",
  #|            "Etc/GMT+12",
  #|            "Etc/GMT+2",
  #|            "Etc/GMT+3",
  #|            "Etc/GMT+4",
  #|            "Etc/GMT+5",
  #|            "Etc/GMT+6",
  #|            "Etc/GMT+7",
  #|            "Etc/GMT+8",
  #|            "Etc/GMT+9",
  #|            "Etc/GMT-0",
  #|            "Etc/GMT-1",
  #|            "Etc/GMT-10",
  #|            "Etc/GMT-11",
  #|            "Etc/GMT-12",
  #|            "Etc/GMT-13",
  #|            "Etc/GMT-14",
  #|            "Etc/GMT-2",
  #|            "Etc/GMT-3",
  #|            "Etc/GMT-4",
  #|            "Etc/GMT-5",
  #|            "Etc/GMT-6",
  #|            "Etc/GMT-7",
  #|            "Etc/GMT-8",
  #|            "Etc/GMT-9",
  #|            "Etc/GMT0",
  #|            "Etc/Greenwich",
  #|            "Etc/UCT",
  #|            "Etc/Universal",
  #|            "Etc/UTC",
  #|            "Etc/Zulu",
  #|            "Europe/Amsterdam",
  #|            "Europe/Andorra",
  #|            "Europe/Astrakhan",
  #|            "Europe/Athens",
  #|            "Europe/Belfast",
  #|            "Europe/Belgrade",
  #|            "Europe/Berlin",
  #|            "Europe/Bratislava",
  #|            "Europe/Brussels",
  #|            "Europe/Bucharest",
  #|            "Europe/Budapest",
  #|            "Europe/Busingen",
  #|            "Europe/Chisinau",
  #|            "Europe/Copenhagen",
  #|            "Europe/Dublin",
  #|            "Europe/Gibraltar",
  #|            "Europe/Guernsey",
  #|            "Europe/Helsinki",
  #|            "Europe/Isle_of_Man",
  #|            "Europe/Istanbul",
  #|            "Europe/Jersey",
  #|            "Europe/Kaliningrad",
  #|            "Europe/Kiev",
  #|            "Europe/Kirov",
  #|            "Europe/Kyiv",
  #|            "Europe/Lisbon",
  #|            "Europe/Ljubljana",
  #|            "Europe/London",
  #|            "Europe/Luxembourg",
  #|            "Europe/Madrid",
  #|            "Europe/Malta",
  #|            "Europe/Mariehamn",
  #|            "Europe/Minsk",
  #|            "Europe/Monaco",
  #|            "Europe/Moscow",
  #|            "Europe/Nicosia",
  #|            "Europe/Oslo",
  #|            "Europe/Paris",
  #|            "Europe/Podgorica",
  #|            "Europe/Prague",
  #|            "Europe/Riga",
  #|            "Europe/Rome",
  #|            "Europe/Samara",
  #|            "Europe/San_Marino",
  #|            "Europe/Sarajevo",
  #|            "Europe/Saratov",
  #|            "Europe/Simferopol",
  #|            "Europe/Skopje",
  #|            "Europe/Sofia",
  #|            "Europe/Stockholm",
  #|            "Europe/Tallinn",
  #|            "Europe/Tirane",
  #|            "Europe/Tiraspol",
  #|            "Europe/Ulyanovsk",
  #|            "Europe/Uzhgorod",
  #|            "Europe/Vaduz",
  #|            "Europe/Vatican",
  #|            "Europe/Vienna",
  #|            "Europe/Vilnius",
  #|            "Europe/Volgograd",
  #|            "Europe/Warsaw",
  #|            "Europe/Zagreb",
  #|            "Europe/Zaporozhye",
  #|            "Europe/Zurich",
  #|            "Factory",
  #|            "GB",
  #|            "GB-Eire",
  #|            "GMT",
  #|            "GMT+0",
  #|            "GMT-0",
  #|            "GMT0",
  #|            "Greenwich",
  #|            "Hongkong",
  #|            "HST",
  #|            "Iceland",
  #|            "Indian/Antananarivo",
  #|            "Indian/Chagos",
  #|            "Indian/Christmas",
  #|            "Indian/Cocos",
  #|            "Indian/Comoro",
  #|            "Indian/Kerguelen",
  #|            "Indian/Mahe",
  #|            "Indian/Maldives",
  #|            "Indian/Mauritius",
  #|            "Indian/Mayotte",
  #|            "Indian/Reunion",
  #|            "Iran",
  #|            "Israel",
  #|            "Jamaica",
  #|            "Japan",
  #|            "Kwajalein",
  #|            "Libya",
  #|            "MET",
  #|            "Mexico/BajaNorte",
  #|            "Mexico/BajaSur",
  #|            "Mexico/General",
  #|            "MST",
  #|            "MST7MDT",
  #|            "Navajo",
  #|            "NZ",
  #|            "NZ-CHAT",
  #|            "Pacific/Apia",
  #|            "Pacific/Auckland",
  #|            "Pacific/Bougainville",
  #|            "Pacific/Chatham",
  #|            "Pacific/Chuuk",
  #|            "Pacific/Easter",
  #|            "Pacific/Efate",
  #|            "Pacific/Enderbury",
  #|            "Pacific/Fakaofo",
  #|            "Pacific/Fiji",
  #|            "Pacific/Funafuti",
  #|            "Pacific/Galapagos",
  #|            "Pacific/Gambier",
  #|            "Pacific/Guadalcanal",
  #|            "Pacific/Guam",
  #|            "Pacific/Honolulu",
  #|            "Pacific/Johnston",
  #|            "Pacific/Kanton",
  #|            "Pacific/Kiritimati",
  #|            "Pacific/Kosrae",
  #|            "Pacific/Kwajalein",
  #|            "Pacific/Majuro",
  #|            "Pacific/Marquesas",
  #|            "Pacific/Midway",
  #|            "Pacific/Nauru",
  #|            "Pacific/Niue",
  #|            "Pacific/Norfolk",
  #|            "Pacific/Noumea",
  #|            "Pacific/Pago_Pago",
  #|            "Pacific/Palau",
  #|            "Pacific/Pitcairn",
  #|            "Pacific/Pohnpei",
  #|            "Pacific/Ponape",
  #|            "Pacific/Port_Moresby",
  #|            "Pacific/Rarotonga",
  #|            "Pacific/Saipan",
  #|            "Pacific/Samoa",
  #|            "Pacific/Tahiti",
  #|            "Pacific/Tarawa",
  #|            "Pacific/Tongatapu",
  #|            "Pacific/Truk",
  #|            "Pacific/Wake",
  #|            "Pacific/Wallis",
  #|            "Pacific/Yap",
  #|            "Poland",
  #|            "Portugal",
  #|            "PRC",
  #|            "PST8PDT",
  #|            "ROC",
  #|            "ROK",
  #|            "Singapore",
  #|            "Turkey",
  #|            "UCT",
  #|            "Universal",
  #|            "US/Alaska",
  #|            "US/Aleutian",
  #|            "US/Arizona",
  #|            "US/Central",
  #|            "US/East-Indiana",
  #|            "US/Eastern",
  #|            "US/Hawaii",
  #|            "US/Indiana-Starke",
  #|            "US/Michigan",
  #|            "US/Mountain",
  #|            "US/Pacific",
  #|            "US/Samoa",
  #|            "UTC",
  #|            "W-SU",
  #|            "WET",
  #|            "Zulu"
  #|          ]
  #|        },
  #|        "license_url": {
  #|          "description":
  #|            "A fully qualified URL of a page that defines the license terms for the GBFS data for this system.",
  #|          "type": "string",
  #|          "format": "uri"
  #|        },
  #|        "brand_assets": {
  #|          "description":
  #|          "An object where each key defines one of the items listed below (added in v2.3-RC).",
  #|          "type": "object",
  #|          "properties": {
  #|            "brand_last_modified": {
  #|              "description": "Date that indicates the last time any included brand assets were updated (added in v2.3-RC).",
  #|              "type": "string",
  #|              "format": "date"
  #|            },
  #|            "brand_terms_url": {
  #|              "description": "A fully qualified URL pointing to the location of a page that defines the license terms of brand icons, colors or other trademark information (added in v2.3-RC).",
  #|              "type": "string",
  #|              "format": "uri"
  #|            },
  #|            "brand_image_url": {
  #|              "description": "A fully qualified URL pointing to the location of a graphic file representing the brand for the service (added in v2.3-RC). ",
  #|              "type": "string",
  #|              "format": "uri"
  #|            },
  #|            "brand_image_url_dark": {
  #|              "description": "A fully qualified URL pointing to the location of a graphic file representing the brand for the service for use in dark mode (added in v2.3-RC).",
  #|              "type": "string",
  #|              "format": "uri"
  #|            },
  #|            "color": {
  #|              "description": "Color used to represent the brand for the service (added in v2.3-RC)",
  #|              "type": "string",
  #|              "pattern": "^#([a-fA-F0-9]{6})$"
  #|            }
  #|          },
  #|          "required": ["brand_last_modified", "brand_image_url"]
  #|        },
  #|        "terms_url": {
  #|          "description":
  #|          "A fully qualified URL pointing to the terms of service (added in v2.3-RC)",
  #|          "type": "string",
  #|          "format": "uri"
  #|        },
  #|        "terms_last_updated": {
  #|          "description":
  #|          "The date that the terms of service provided at terms_url were last updated (added in v2.3-RC)",
  #|          "type": "string",
  #|          "format": "date"
  #|        },
  #|        "privacy_url": {
  #|          "description":
  #|          "A fully qualified URL pointing to the privacy policy for the service (added in v2.3-RC).",
  #|          "type": "string",
  #|          "format": "uri"
  #|        },
  #|        "privacy_last_updated": {
  #|          "description":
  #|          "The date that the privacy policy provided at privacy_url was last updated (added in v2.3-RC).",
  #|          "type": "string",
  #|          "format": "date"
  #|        },
  #|        "rental_apps": {
  #|          "description":
  #|            "Contains rental app information in the android and ios JSON objects (added in v1.1).",
  #|          "type": "object",
  #|          "properties": {
  #|            "android": {
  #|              "description":
  #|                "Contains rental app download and app discovery information for the Android platform. (added in v1.1)",
  #|              "type": "object",
  #|              "properties": {
  #|                "store_uri": {
  #|                  "description":
  #|                    "URI where the rental Android app can be downloaded from (added in v1.1).",
  #|                  "type": "string",
  #|                  "format": "uri"
  #|                },
  #|                "discovery_uri": {
  #|                  "description":
  #|                    "URI that can be used to discover if the rental Android app is installed on the device (added in v1.1).",
  #|                  "type": "string",
  #|                  "format": "uri"
  #|                }
  #|              },
  #|              "required": ["store_uri", "discovery_uri"]
  #|            },
  #|            "ios": {
  #|              "description":
  #|                "Contains rental information for the iOS platform (added in v1.1).",
  #|              "type": "object",
  #|              "properties": {
  #|                "store_uri": {
  #|                  "description":
  #|                    "URI where the rental iOS app can be downloaded from (added in v1.1).",
  #|                  "type": "string",
  #|                  "format": "uri"
  #|                },
  #|                "discovery_uri": {
  #|                  "description":
  #|                    "URI that can be used to discover if the rental iOS app is installed on the device (added in v1.1).",
  #|                  "type": "string",
  #|                  "format": "uri"
  #|                }
  #|              },
  #|              "required": ["store_uri", "discovery_uri"]
  #|            }
  #|          }
  #|        }
  #|      },
  #|      "required": ["system_id", "language", "name", "timezone"],
  #|      "dependencies": {
  #|        "terms_url": ["terms_last_updated"],
  #|        "privacy_url": ["privacy_last_updated"]
  #|      }
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_station_information : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#station_informationjson",
  #|  "description":
  #|    "List of all stations, their capacities and locations. REQUIRED of systems utilizing docks.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description":
  #|        "Array that contains one object per station as defined below.",
  #|      "type": "object",
  #|      "properties": {
  #|        "stations": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "station_id": {
  #|                "description": "Identifier of a station.",
  #|                "type": "string"
  #|              },
  #|              "name": {
  #|                "description": "Public name of the station.",
  #|                "type": "string"
  #|              },
  #|              "short_name": {
  #|                "description": "Short name or other type of identifier.",
  #|                "type": "string"
  #|              },
  #|              "lat": {
  #|                "description": "The latitude of the station.",
  #|                "type": "number",
  #|                "minimum": -90,
  #|                "maximum": 90
  #|              },
  #|              "lon": {
  #|                "description": "The longitude fo the station.",
  #|                "type": "number",
  #|                "minimum": -180,
  #|                "maximum": 180
  #|              },
  #|              "address": {
  #|                "description": "Address where station is located.",
  #|                "type": "string"
  #|              },
  #|              "cross_street": {
  #|                "description":
  #|                  "Cross street or landmark where the station is located.",
  #|                "type": "string"
  #|              },
  #|              "region_id": {
  #|                "description":
  #|                  "Identifier of the region where the station is located.",
  #|                "type": "string"
  #|              },
  #|              "post_code": {
  #|                "description": "Postal code where station is located.",
  #|                "type": "string"
  #|              },
  #|              "rental_methods": {
  #|                "description": "Payment methods accepted at this station.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "string",
  #|                  "enum": [
  #|                    "key",
  #|                    "creditcard",
  #|                    "paypass",
  #|                    "applepay",
  #|                    "androidpay",
  #|                    "transitcard",
  #|                    "accountnumber",
  #|                    "phone"
  #|                  ]
  #|                },
  #|                "minItems": 1
  #|              },
  #|              "is_virtual_station": {
  #|                "description":
  #|                  "Is this station a location with or without physical infrastructure? (added in v2.1-RC)",
  #|                "type": "boolean"
  #|              },
  #|              "station_area": {
  #|                "description":
  #|                  "A multipolygon that describes the area of a virtual station (added in v2.1-RC).",
  #|                "type": "object",
  #|                "required": ["type", "coordinates"],
  #|                "properties": {
  #|                  "type": {
  #|                    "type": "string",
  #|                    "enum": ["MultiPolygon"]
  #|                  },
  #|                  "coordinates": {
  #|                    "type": "array",
  #|                    "items": {
  #|                      "type": "array",
  #|                      "items": {
  #|                        "type": "array",
  #|                        "minItems": 4,
  #|                        "items": {
  #|                          "type": "array",
  #|                          "minItems": 2,
  #|                          "items": {
  #|                            "type": "number"
  #|                          }
  #|                        }
  #|                      }
  #|                    }
  #|                  }
  #|                }
  #|              },
  #|              "parking_type": {
  #|                "description": "Type of parking station. Added in v2.3",
  #|                  "type": "string",
  #|                  "enum": [
  #|                    "parking_lot",
  #|                    "street_parking",
  #|                    "underground_parking",
  #|                    "sidewalk_parking",
  #|                    "other"
  #|                  ]
  #|                },
  #|              "parking_hoop": {
  #|                "description": "Are parking hoops present at this station? Added in v2.3",
  #|                "type": "boolean"
  #|              },
  #|              "contact_phone": {
  #|                "description": "Contact phone of the station. Added in v2.3",
  #|                "type": "string"
  #|              },
  #|              "capacity": {
  #|                "description":
  #|                  "Number of total docking points installed at this station, both available and unavailable.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "vehicle_capacity": {
  #|                "description":
  #|                  "An object where each key is a vehicle_type_id and the value is a number presenting the total number of vehicles of this type that can park within the station_area (added in v2.1-RC).",
  #|                "type": "object",
  #|                "additionalProperties": {
  #|                  "type": "number"
  #|                }
  #|              },
  #|              "is_valet_station": {
  #|                "description":
  #|                  "Are valet services provided at this station? (added in v2.1-RC)",
  #|                "type": "boolean"
  #|              },
  #|              "is_charging_station": {
  #|                "description":
  #|                "Does the station support charging of electric vehicles? (added in v2.3-RC)",
  #|                "type": "boolean"
  #|              },
  #|              "rental_uris": {
  #|                "description":
  #|                  "Contains rental uris for Android, iOS, and web in the android, ios, and web fields (added in v1.1).",
  #|                "type": "object",
  #|                "properties": {
  #|                  "android": {
  #|                    "description":
  #|                      "URI that can be passed to an Android app with an intent (added in v1.1).",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  },
  #|                  "ios": {
  #|                    "description":
  #|                      "URI that can be used on iOS to launch the rental app for this station (added in v1.1).",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  },
  #|                  "web": {
  #|                    "description":
  #|                      "URL that can be used by a web browser to show more information about renting a vehicle at this station (added in v1.1).",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  }
  #|                }
  #|              },
  #|              "vehicle_type_capacity": {
  #|                "description":
  #|                  "An object where each key is a vehicle_type_id and the value is a number representing the total docking points installed at this station for each vehicle type (added in v2.1-RC).",
  #|                "type": "object",
  #|                "additionalProperties": {
  #|                  "type": "number"
  #|                }
  #|              }
  #|            },
  #|            "required": ["station_id", "name", "lat", "lon"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["stations"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_station_status : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#station_statusjson",
  #|  "description":
  #|    "Describes the capacity and rental availability of the station",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description":
  #|        "Array that contains one object per station as defined below.",
  #|      "type": "object",
  #|      "properties": {
  #|        "stations": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "station_id": {
  #|                "description": "Identifier of a station.",
  #|                "type": "string"
  #|              },
  #|              "num_bikes_available": {
  #|                "description":
  #|                  "Number of vehicles of any type physically available for rental at the station.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "vehicle_types_available": {
  #|                "description":
  #|                  "Array of objects displaying the total number of each vehicle type at the station (added in v2.1-RC).",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "vehicle_type_id": {
  #|                      "description":
  #|                        "The vehicle_type_id of vehicle at the station (added in v2.1-RC).",
  #|                      "type": "string"
  #|                    },
  #|                    "count": {
  #|                      "description":
  #|                        "A number representing the total amount of this vehicle type at the station (added in v2.1-RC).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    }
  #|                  },
  #|                  "required": ["vehicle_type_id", "count"]
  #|                }
  #|              },
  #|              "num_bikes_disabled": {
  #|                "description":
  #|                  "Number of disabled vehicles of any type at the station.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "num_docks_available": {
  #|                "description":
  #|                  "Number of functional docks physically at the station.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "num_docks_disabled": {
  #|                "description":
  #|                  "Number of empty but disabled docks at the station.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "is_installed": {
  #|                "description": "Is the station currently on the street?",
  #|                "type": "boolean"
  #|              },
  #|              "is_renting": {
  #|                "description": "Is the station currently renting vehicles?",
  #|                "type": "boolean"
  #|              },
  #|              "is_returning": {
  #|                "description": "Is the station accepting vehicle returns?",
  #|                "type": "boolean"
  #|              },
  #|              "last_reported": {
  #|                "description":
  #|                  "The last time this station reported its status to the operator's backend in POSIX time.",
  #|                "type": "integer",
  #|                "minimum": 1450155600
  #|              },
  #|              "vehicle_docks_available": {
  #|                "description":
  #|                  "Object displaying available docks by vehicle type (added in v2.1-RC).",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "vehicle_type_ids": {
  #|                      "description":
  #|                        "An array of strings where each string represents a vehicle_type_id that is able to use a particular type of dock at the station (added in v2.1-RC).",
  #|                      "type": "array",
  #|                      "items": {
  #|                        "type": "string"
  #|                      }
  #|                    },
  #|                    "count": {
  #|                      "description":
  #|                        "A number representing the total number of available docks for the defined vehicle type (added in v2.1-RC).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    }
  #|                  },
  #|                  "required": ["vehicle_type_ids", "count"]
  #|                }
  #|              }
  #|            },
  #|            "required": [
  #|              "station_id",
  #|              "num_bikes_available",
  #|              "is_installed",
  #|              "is_renting",
  #|              "is_returning",
  #|              "last_reported"
  #|            ]
  #|          }
  #|        }
  #|      },
  #|      "required": ["stations"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_free_bike_status : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#free_bike_statusjson",
  #|  "description":
  #|    "Describes the vehicles that are available for rent (as of v2.1-RC2).",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description":
  #|        "Array that contains one object per bike as defined below.",
  #|      "type": "object",
  #|      "properties": {
  #|        "bikes": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "bike_id": {
  #|                "description": "Rotating (as of v2.0) identifier of a vehicle.",
  #|                "type": "string"
  #|              },
  #|              "lat": {
  #|                "description": "The latitude of the vehicle.",
  #|                "type": "number",
  #|                "minimum": -90,
  #|                "maximum": 90
  #|              },
  #|              "lon": {
  #|                "description": "The longitude of the vehicle.",
  #|                "type": "number",
  #|                "minimum": -180,
  #|                "maximum": 180
  #|              },
  #|              "is_reserved": {
  #|                "description": "Is the vehicle currently reserved?",
  #|                "type": "boolean"
  #|              },
  #|              "is_disabled": {
  #|                "description": "Is the vehicle currently disabled (broken)?",
  #|                "type": "boolean"
  #|              },
  #|              "rental_uris": {
  #|                "description": "Contains rental uris for Android, iOS, and web in the android, ios, and web fields (added in v1.1).",
  #|                "type": "object",
  #|                "properties": {
  #|                  "android": {
  #|                    "description": "URI that can be passed to an Android app with an intent (added in v1.1).",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  },
  #|                  "ios": {
  #|                    "description": "URI that can be used on iOS to launch the rental app for this vehicle (added in v1.1).",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  },
  #|                  "web": {
  #|                    "description": "URL that can be used by a web browser to show more information about renting this vehicle (added in v1.1).",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  }
  #|                }
  #|              },
  #|              "vehicle_type_id": {
  #|                "description": "The vehicle_type_id of this vehicle (added in v2.1-RC).",
  #|                "type": "string"
  #|              },
  #|              "last_reported": {
  #|                "description": "The last time this vehicle reported its status to the operator's backend in POSIX time (added in v2.1-RC).",
  #|                "type": "integer",
  #|                "minimum": 1450155600
  #|              },
  #|              "current_range_meters": {
  #|                "description": "The furthest distance in meters that the vehicle can travel without recharging or refueling with the vehicle's current charge or fuel (added in v2.1-RC).",
  #|                "type": "number",
  #|                "minimum": 0
  #|              },
  #|              "current_fuel_percent": {
  #|                "description": "This value represents the current percentage, expressed from 0 to 1, of fuel or battery power remaining in the vehicle. Added in v2.3-RC.",
  #|                "type": "number",
  #|                "minimum": 0,
  #|                "maximum": 1
  #|              },
  #|              "station_id": {
  #|                "description": "Identifier referencing the station_id if the vehicle is currently at a station (added in v2.1-RC2).",
  #|                "type": "string"
  #|              },
  #|              "home_station_id": {
  #|                "description": "The station_id of the station this vehicle must be returned to (added in v2.3-RC).",
  #|                "type": "string"
  #|              },
  #|              "pricing_plan_id": {
  #|                "description": "The plan_id of the pricing plan this vehicle is eligible for (added in v2.2).",
  #|                "type": "string"
  #|              },
  #|              "vehicle_equipment": {
  #|                "description": "List of vehicle equipment provided by the operator in addition to the accessories already provided in the vehicle. Added in v2.3.",
  #|                "type": "array",
  #|                "items": {
  #|                  "enum": ["child_seat_a", "child_seat_b", "child_seat_c", "winter_tires", "snow_chains"]
  #|                }
  #|              },
  #|              "available_until": {
  #|                "description": "The date and time when any rental of the vehicle must be completed. Added in v2.3.",
  #|                "type": "string",
  #|                "pattern": "^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(([+-]([0-9]{2}):([0-9]{2}))|Z)$"
  #|              }
  #|            },
  #|            "anyOf": [
  #|              {
  #|                "required": ["lat", "lon"],
  #|                "errorMessage": "Both 'lat' and 'lon' are required."
  #|              },
  #|              {
  #|                "required": ["station_id"],
  #|                "properties": {
  #|                  "lat": {
  #|                    "not": {}
  #|                  },
  #|                  "lon": {
  #|                    "not": {}
  #|                  }
  #|                },
  #|                "errorMessage": "'station_id' is required if 'lat' and 'lon' are not present."
  #|              }
  #|            ],
  #|            "required": ["bike_id", "is_reserved", "is_disabled"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["bikes"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_vehicle_types : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#vehicle_typesjson",
  #|  "description":
  #|    "Describes the types of vehicles that System operator has available for rent (added in v2.1-RC).",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework.",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Response data in the form of name:value pairs.",
  #|      "type": "object",
  #|      "properties": {
  #|        "vehicle_types": {
  #|          "description":
  #|          "Array that contains one object per vehicle type in the system as defined below.",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "vehicle_type_id": {
  #|                "description": "Unique identifier of a vehicle type.",
  #|                "type": "string"
  #|              },
  #|              "form_factor": {
  #|                "description": "The vehicle's general form factor.",
  #|                "type": "string",
  #|                "enum": ["bicycle", "cargo_bicycle" ,"car", "moped", "scooter_standing", "scooter_seated", "other", "scooter"]
  #|              },
  #|              "rider_capacity": {
  #|                "description": "The number of riders (driver included) the vehicle can legally accommodate",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "cargo_volume_capacity": {
  #|                "description": "Cargo volume available in the vehicle, expressed in liters.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "cargo_load_capacity": {
  #|                "description": "The capacity of the vehicle cargo space (excluding passengers), expressed in kilograms.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|
  #|              "propulsion_type": {
  #|                "description": "The primary propulsion type of the vehicle. Updated in v2.3 to represent car-sharing",
  #|                "type": "string",
  #|                "enum": ["human", "electric_assist", "electric", "combustion", "combustion_diesel", "hybrid", "plug_in_hybrid", "hydrogen_fuel_cell"]
  #|              },
  #|              "eco_label": {
  #|                "description": "Vehicle air quality certificate. added in v2.3.",
  #|                "type": "array",
  #|                "items":  {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "country_code": {
  #|                      "description": " Country code following the ISO 3166-1 alpha-2 notation. Added in v2.3.",
  #|                      "type": "string",
  #|                      "pattern": "^[A-Z]{2}"
  #|                    },
  #|                    "eco_sticker": {
  #|                      "description": " Name of the eco label. Added in v2.3.",
  #|                      "type": "string"
  #|                    }
  #|                  },
  #|                  "required": ["country_code", "eco_sticker"]
  #|                }
  #|              },
  #|              "max_range_meters": {
  #|                "description":
  #|                "The furthest distance in meters that the vehicle can travel without recharging or refueling when it has the maximum amount of energy potential.",
  #|                "type": "number",
  #|                "minimum": 0
  #|              },
  #|              "name": {
  #|                "description": "The public name of this vehicle type.",
  #|                "type": "string"
  #|              },
  #|              "vehicle_accessories": {
  #|                "description": "Description of accessories available in the vehicle.",
  #|                "type": "array",
  #|                "items": {
  #|                  "enum": ["air_conditioning", "automatic", "manual", "convertible", "cruise_control", "doors_2", "doors_3", "doors_4", "doors_5", "navigation"]
  #|                }
  #|              },
  #|              "g_CO2_km": {
  #|                "description": "Maximum quantity of CO2, in grams, emitted per kilometer, according to the WLTP. Added in v2.3",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "vehicle_image": {
  #|                "description": "URL to an image that would assist the user in identifying the vehicle. JPEG or PNG. Added in v2.3",
  #|                "type": "string",
  #|                "format": "uri"
  #|              },
  #|              "make": {
  #|                "description": "The name of the vehicle manufacturer. Added in v2.3",
  #|                "type": "string"
  #|              },
  #|              "model": {
  #|                "description": "The name of the vehicle model. Added in v2.3",
  #|                "type": "string"
  #|              },
  #|              "color": {
  #|                "description": "The color of the vehicle. Added in v2.3",
  #|                "type": "string"
  #|              },
  #|              "wheel_count": {
  #|                "description": "Number of wheels this vehicle type has. Added in v2.3",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "max_permitted_speed": {
  #|                "description": "The maximum speed in kilometers per hour this vehicle is permitted to reach in accordance with local permit and regulations. Added in v2.3",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "rated_power": {
  #|                "description": "The rated power of the motor for this vehicle type in watts. Added in v2.3",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "default_reserve_time": {
  #|                "description": "Maximum time in minutes that a vehicle can be reserved before a rental begins added in v2.3-RC.",
  #|                "type": "integer",
  #|                "minimum": 0
  #|              },
  #|              "return_constraint": {
  #|                "description": "The conditions for returning the vehicle at the end of the trip. Added in v2.3-RC as return_type, and updated to return_constraint in v2.3.",
  #|                "type": "string",
  #|                "enum": ["free_floating", "roundtrip_station", "any_station", "hybrid"]
  #|              },
  #|              "vehicle_assets": {
  #|                "description": "An object where each key defines one of the items listed below added in v2.3-RC.",
  #|                "type": "object",
  #|                "properties": {
  #|                  "icon_url": {
  #|                    "description": "A fully qualified URL pointing to the location of a graphic icon file that MAY be used to represent this vehicle type on maps and in other applications added in v2.3-RC.",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  },
  #|                  "icon_url_dark": {
  #|                    "description": "A fully qualified URL pointing to the location of a graphic icon file to be used to represent this vehicle type when in dark mode added in v2.3-RC.",
  #|                    "type": "string",
  #|                    "format": "uri"
  #|                  },
  #|                  "icon_last_modified": {
  #|                    "description": "Date that indicates the last time any included vehicle icon images were modified or updated added in v2.3-RC.",
  #|                    "type": "string",
  #|                    "format": "date"
  #|                  }
  #|                },
  #|                "required": ["icon_url", "icon_last_modified"]
  #|              },
  #|              "default_pricing_plan_id": {
  #|                "description": "A plan_id as defined in system_pricing_plans.json added in v2.3-RC.",
  #|                "type": "string"
  #|              },
  #|              "pricing_plan_ids": {
  #|                "description": "Array of all pricing plan IDs as defined in system_pricing_plans.json added in v2.3-RC.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "string"
  #|                }
  #|              }
  #|            },
  #|            "required": ["vehicle_type_id", "form_factor", "propulsion_type"],
  #|            "if": {
  #|              "properties": {
  #|                "propulsion_type": {
  #|                  "enum": ["electric", "electric_assist", "combustion", "combustion_diesel", "hybrid", "plug_in_hybrid", "hydrogen_fuel_cell"]
  #|                }
  #|              }
  #|            },
  #|            "then": {
  #|              "required": ["max_range_meters"]
  #|            }
  #|          }
  #|        }
  #|      },
  #|      "required": ["vehicle_types"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_system_hours : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#system_hoursjson",
  #|  "description": "Describes the system hours of operation.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Array that contains system hours of operations.",
  #|      "type": "object",
  #|      "properties": {
  #|        "rental_hours": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "user_types": {
  #|                "description":
  #|                  "Array of member and nonmember value(s) indicating that this set of rental hours applies to either members or non-members only.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "string",
  #|                  "enum": ["member", "nonmember"]
  #|                },
  #|                "minItems": 1,
  #|                "maxItems": 2
  #|              },
  #|              "days": {
  #|                "description":
  #|                  "An array of abbreviations (first 3 letters) of English names of the days of the week for which this object applies.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "string",
  #|                  "enum": ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
  #|                },
  #|                "minItems": 1,
  #|                "maxItems": 7
  #|              },
  #|              "start_time": {
  #|                "description":
  #|                  "Start time for the hours of operation of the system.",
  #|                "type": "string",
  #|                "pattern": "^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"
  #|              },
  #|              "end_time": {
  #|                "description":
  #|                  "End time for the hours of operation of the system.",
  #|                "type": "string",
  #|                "pattern": "^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"
  #|              }
  #|            },
  #|            "required": ["user_types", "days", "start_time", "end_time"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["rental_hours"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_system_alerts : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#system_alertsjson",
  #|  "description": "Describes ad-hoc changes to the system.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Array that contains ad-hoc alerts for the system.",
  #|      "type": "object",
  #|      "properties": {
  #|        "alerts": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "alert_id": {
  #|                "description": "Identifier for this alert.",
  #|                "type": "string"
  #|              },
  #|              "type": {
  #|                "description": "Type of alert.",
  #|                "type": "string",
  #|                "enum": [
  #|                  "system_closure",
  #|                  "station_closure",
  #|                  "station_move",
  #|                  "other"
  #|                ]
  #|              },
  #|              "times": {
  #|                "description":
  #|                  "Array of objects indicating when the alert is in effect.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "start": {
  #|                      "description": "Start time of the alert.",
  #|                      "type": "integer",
  #|                      "minimum": 1450155600
  #|                    },
  #|                    "end": {
  #|                      "description": "End time of the alert.",
  #|                      "type": "integer",
  #|                      "minimum": 1450155600
  #|                    }
  #|                  }
  #|                },
  #|                "additionalItems": false,
  #|                "required": ["start"]
  #|              },
  #|              "station_ids": {
  #|                "description":
  #|                  "Array of identifiers of the stations for which this alert applies.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "string"
  #|                }
  #|              },
  #|              "region_ids": {
  #|                "description":
  #|                  "Array of identifiers of the regions for which this alert applies.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "string"
  #|                }
  #|              },
  #|              "url": {
  #|                "description":
  #|                  "URL where the customer can learn more information about this alert.",
  #|                "type": "string",
  #|                "format": "uri"
  #|              },
  #|              "summary": {
  #|                "description":
  #|                  "A short summary of this alert to be displayed to the customer.",
  #|                "type": "string"
  #|              },
  #|              "description": {
  #|                "description": "Detailed description of the alert.",
  #|                "type": "string"
  #|              },
  #|              "last_updated": {
  #|                "description":
  #|                  "Indicates the last time the info for the alert was updated.",
  #|                "type": "number",
  #|                "minimum": 1450155600
  #|              }
  #|            },
  #|            "required": ["alert_id", "type", "summary"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["alerts"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_system_calendar : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#system_calendarjson",
  #|  "description": "Describes the operating calendar for a system.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Array that contains opertions calendar for the system.",
  #|      "type": "object",
  #|      "properties": {
  #|        "calendars": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "start_month": {
  #|                "description": "Starting month for the system operations.",
  #|                "type": "integer",
  #|                "minimum": 1,
  #|                "maximum": 12
  #|              },
  #|              "start_day": {
  #|                "description": "Starting day for the system operations.",
  #|                "type": "integer",
  #|                "minimum": 1,
  #|                "maximum": 31
  #|              },
  #|              "start_year": {
  #|                "description": "Starting year for the system operations.",
  #|                "type": "integer",
  #|                "pattern": "^\\d{4}$"
  #|              },
  #|              "end_month": {
  #|                "description": "End month for the system operations.",
  #|                "type": "integer",
  #|                "minimum": 1,
  #|                "maximum": 12
  #|              },
  #|              "end_day": {
  #|                "description": "End day for the system operations.",
  #|                "type": "integer",
  #|                "minimum": 1,
  #|                "maximum": 31
  #|              },
  #|              "end_year": {
  #|                "description": "End year for the system operations.",
  #|                "type": "integer",
  #|                "pattern": "^\\d{4}$"
  #|              }
  #|            },
  #|            "required": ["start_month", "start_day", "end_month", "end_day"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["calendars"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_system_regions : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#system_regionsjson",
  #|  "description":
  #|    "Describes regions for a system that is broken up by geographic or political region.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Describe regions for a system that is broken up by geographic or political region.",
  #|      "type": "object",
  #|      "properties": {
  #|        "regions": {
  #|          "description": "Array of regions.",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "region_id": {
  #|                "description": "identifier of the region.",
  #|                "type": "string"
  #|              },
  #|              "name": {
  #|                "description": "Public name for this region.",
  #|                "type": "string"
  #|              }
  #|            },
  #|            "required": ["region_id", "name"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["regions"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_system_pricing_plans : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#system_pricing_plansjson",
  #|  "description": "Describes the pricing schemes of the system.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description":
  #|        "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description":
  #|        "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description":
  #|        "Array that contains one object per plan as defined below.",
  #|      "type": "object",
  #|      "properties": {
  #|        "plans": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "plan_id": {
  #|                "description": "Identifier of a pricing plan in the system.",
  #|                "type": "string"
  #|              },
  #|              "url": {
  #|                "description":
  #|                  "URL where the customer can learn more about this pricing plan.",
  #|                "type": "string",
  #|                "format": "uri"
  #|              },
  #|              "name": {
  #|                "description": "Name of this pricing plan.",
  #|                "type": "string"
  #|              },
  #|              "currency": {
  #|                "description":
  #|                  "Currency used to pay the fare in ISO 4217 code.",
  #|                "type": "string",
  #|                "pattern": "^\\w{3}$"
  #|              },
  #|              "price": {
  #|                "description": "Fare price.",
  #|                "type": "number",
  #|                "minimum": 0
  #|              },
  #|              "is_taxable": {
  #|                "description":
  #|                  "Will additional tax be added to the base price?",
  #|                "type": "boolean"
  #|              },
  #|              "description": {
  #|                "description":
  #|                  "Customer-readable description of the pricing plan.",
  #|                "type": "string"
  #|              },
  #|              "per_km_pricing": {
  #|                "description":
  #|                  "Array of segments when the price is a function of distance travelled, displayed in kilometers (added in v2.1-RC2).",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "start": {
  #|                      "description":
  #|                        "Number of kilometers that have to elapse before this segment starts applying (added in v2.1-RC2).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    },
  #|                    "rate": {
  #|                      "description":
  #|                        "Rate that is charged for each kilometer interval after the start (added in v2.1-RC2).",
  #|                      "type": "number"
  #|                    },
  #|                    "interval": {
  #|                      "description":
  #|                        "Interval in kilometers at which the rate of this segment is either reapplied indefinitely, or if defined, up until (but not including) end kilometer (added in v2.1-RC2).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    },
  #|                    "end": {
  #|                      "description":
  #|                        "The kilometer at which the rate will no longer apply (added in v2.1-RC2).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    }
  #|                  },
  #|                  "required": ["start", "rate", "interval"]
  #|                }
  #|              },
  #|              "per_min_pricing": {
  #|                "description":
  #|                  "Array of segments when the price is a function of time travelled, displayed in minutes (added in v2.1-RC2).",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "start": {
  #|                      "description":
  #|                        "Number of minutes that have to elapse before this segment starts applying (added in v2.1-RC2).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    },
  #|                    "rate": {
  #|                      "description":
  #|                        "Rate that is charged for each minute interval after the start (added in v2.1-RC2).",
  #|                      "type": "number"
  #|                    },
  #|                    "interval": {
  #|                      "description":
  #|                        "Interval in minutes at which the rate of this segment is either reapplied (added in v2.1-RC2).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    },
  #|                    "end": {
  #|                      "description":
  #|                        "The minute at which the rate will no longer apply (added in v2.1-RC2).",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    }
  #|                  },
  #|                  "required": ["start", "rate", "interval"]
  #|                }
  #|              },
  #|              "surge_pricing": {
  #|                "description":
  #|                  "Is there currently an increase in price in response to increased demand in this pricing plan? (added in v2.1-RC2)",
  #|                "type": "boolean"
  #|              }
  #|            },
  #|            "required": [
  #|              "plan_id",
  #|              "name",
  #|              "currency",
  #|              "price",
  #|              "is_taxable",
  #|              "description"
  #|            ]
  #|          }
  #|        }
  #|      },
  #|      "required": ["plans"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_v23_geofencing_zones : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v2.3/gbfs.md#geofencing_zonesjson",
  #|  "description":
  #|    "Describes geofencing zones and their associated rules and attributes (added in v2.1-RC).",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in POSIX time.",
  #|      "type": "integer",
  #|      "minimum": 1450155600
  #|    },
  #|    "ttl": {
  #|      "description": "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description": "GBFS version number to which the feed conforms, according to the versioning framework.",
  #|      "type": "string",
  #|      "const": "2.3"
  #|    },
  #|    "data": {
  #|      "description": "Array that contains geofencing information for the system.",
  #|      "type": "object",
  #|      "properties": {
  #|        "geofencing_zones": {
  #|          "type": "object",
  #|          "description": "Each geofenced zone and its associated rules and attributes is described as an object within the array of features.",
  #|          "properties": {
  #|            "type": {
  #|              "description": "FeatureCollection as per IETF RFC 7946.",
  #|              "type": "string",
  #|              "enum": ["FeatureCollection"]
  #|            },
  #|            "features": {
  #|              "description": "Array of objects.",
  #|              "type": "array",
  #|              "items": {
  #|                "title": "GeoJSON Feature",
  #|                "type": "object",
  #|                "properties": {
  #|                  "type": {
  #|                    "type": "string",
  #|                    "enum": ["Feature"]
  #|                  },
  #|                  "properties": {
  #|                    "description":
  #|                      "Describing travel allowances and limitations.",
  #|                    "type": "object",
  #|                    "properties": {
  #|                      "name": {
  #|                        "description": "Public name of the geofencing zone.",
  #|                        "type": "string"
  #|                      },
  #|                      "start": {
  #|                        "description": "Start time of the geofencing zone in POSIX time.",
  #|                        "type": "integer",
  #|                        "minimum": 1450155600
  #|                      },
  #|                      "end": {
  #|                        "description": "End time of the geofencing zone in POSIX time.",
  #|                        "type": "integer",
  #|                        "minimum": 1450155600
  #|                      },
  #|                      "rules": {
  #|                        "description": "Array that contains one object per rule.",
  #|                        "type": "array",
  #|                        "items": {
  #|                          "type": "object",
  #|                          "properties": {
  #|                            "vehicle_type_id": {
  #|                              "type": "array",
  #|                              "description": "Array of vehicle type IDs for which these restrictions apply.",
  #|                              "items": { "type": "string" }
  #|                            },
  #|                            "ride_allowed": {
  #|                              "description": "Is the undocked ride allowed to start and end in this zone?",
  #|                              "type": "boolean"
  #|                            },
  #|                            "ride_through_allowed": {
  #|                              "description":
  #|                                "Is the ride allowed to travel through this zone?",
  #|                              "type": "boolean"
  #|                            },
  #|                            "maximum_speed_kph": {
  #|                              "description": "What is the maximum speed allowed, in kilometers per hour?",
  #|                              "type": "integer",
  #|                              "minimum": 0
  #|                            },
  #|                            "station_parking": {
  #|                              "description": "Vehicle MUST be parked at stations defined in station_information.json within this geofence zone",
  #|                              "type": "boolean"
  #|                            }
  #|                          },
  #|                          "required": ["ride_allowed", "ride_through_allowed"]
  #|                        }
  #|                      }
  #|                    }
  #|                  },
  #|                  "geometry": {
  #|                    "description":
  #|                      "A polygon that describes where rides might not be able to start, end, go through, or have other limitations. Must follow the right-hand rule.",
  #|                    "title": "GeoJSON MultiPolygon",
  #|                    "type": "object",
  #|                    "properties": {
  #|                      "type": {
  #|                        "type": "string",
  #|                        "enum": ["MultiPolygon"]
  #|                      },
  #|                      "coordinates": {
  #|                        "type": "array",
  #|                        "items": {
  #|                          "type": "array",
  #|                          "items": {
  #|                            "type": "array",
  #|                            "minItems": 4,
  #|                            "items": {
  #|                              "type": "array",
  #|                              "minItems": 2,
  #|                              "items": {
  #|                                "type": "number"
  #|                              }
  #|                            }
  #|                          }
  #|                        }
  #|                      }
  #|                    },
  #|                    "required": ["type", "coordinates"]
  #|                  }
  #|                },
  #|                "required": ["type", "geometry", "properties"]
  #|              }
  #|            }
  #|          },
  #|          "required": ["type", "features"]
  #|        }
  #|      },
  #|      "required": ["geofencing_zones"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}
