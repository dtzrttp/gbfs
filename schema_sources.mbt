// 由 tools/embed-schemas.cjs 从原始 GBFS 3.0 Schema 生成。

///|
let schema_gbfs : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v3.0/gbfs.md#gbfsjson",
  #|  "description": "Auto-discovery file that links to all of the other files published by the system.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description": "Last time the data in the feed was updated in RFC3339 format.",
  #|      "type": "string",
  #|      "format": "date-time"
  #|    },
  #|    "ttl": {
  #|      "description": "Number of seconds before the data in the feed will be updated again (0 if the data should always be refreshed).",
  #|      "type": "integer",
  #|      "minimum": 0
  #|    },
  #|    "version": {
  #|      "description": "GBFS version number to which the feed conforms, according to the versioning framework (added in v1.1).",
  #|      "type": "string",
  #|      "const": "3.0"
  #|    },
  #|    "data": {
  #|      "type": "object",
  #|      "properties": {
  #|        "feeds": {
  #|          "description": "An array of all of the feeds that are published by the auto-discovery file. Each element in the array is an object with the keys below.",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "name": {
  #|                "description": "Key identifying the type of feed this is. The key must be the base file name defined in the spec for the corresponding feed type.",
  #|                "type": "string",
  #|                "enum": [
  #|                  "gbfs",
  #|                  "gbfs_versions",
  #|                  "system_information",
  #|                  "vehicle_types",
  #|                  "station_information",
  #|                  "station_status",
  #|                  "vehicle_status",
  #|                  "system_alerts",
  #|                  "system_regions",
  #|                  "system_pricing_plans",
  #|                  "geofencing_zones"
  #|                ]
  #|              },
  #|              "url": {
  #|                "description": "URL for the feed.",
  #|                "type": "string",
  #|                "format": "uri"
  #|              }
  #|            },
  #|            "required": ["name", "url"]
  #|          },
  #|          "minItems": 1,
  #|          "contains": {
  #|            "properties": {
  #|              "name": { "const": "system_information" }
  #|            }
  #|          },
  #|          "allOf": [
  #|            {
  #|              "anyOf": [
  #|                {
  #|                  "contains": {
  #|                    "properties": {
  #|                      "name": { "const": "station_status" }
  #|                    }
  #|                  }
  #|                },
  #|                {
  #|                  "contains": {
  #|                    "properties": {
  #|                      "name": { "const": "vehicle_status" }
  #|                    }
  #|                  }
  #|                }
  #|              ]
  #|            },
  #|            {
  #|              "if": {
  #|                "contains": {
  #|                  "properties": {
  #|                    "name": { "const": "station_information" }
  #|                  }
  #|                }
  #|              },
  #|              "then": {
  #|                "contains": {
  #|                  "properties": {
  #|                    "name": { "const": "station_status" }
  #|                  }
  #|                }
  #|              }
  #|            }
  #|          ]
  #|        }
  #|      },
  #|      "required": ["feeds"]
  #|    }
  #|  },
  #|  "additionalProperties": false,
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_system_information : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v3.0/gbfs.md#system_informationjson",
  #|  "description":
  #|    "Details including system operator, system location, year implemented, URL, contact info, time zone.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in RFC3339 format.",
  #|      "type": "string",
  #|      "format": "date-time"
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
  #|      "const": "3.0"
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
  #|        "languages": {
  #|          "description":
  #|            "List of languages used in translated strings. Each element in the list must be of type Language.",
  #|          "type": "array",
  #|          "items": {
  #|            "description": "IETF BCP 47 language code.",
  #|            "type": "string",
  #|            "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|          }
  #|        },
  #|        "name": {
  #|          "description": "Name of the system to be displayed to customers. An array with one object per supported language with the following keys:",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "text": {
  #|                "description": "The translated text.",
  #|                "type": "string"
  #|              },
  #|              "language": {
  #|                "description": "IETF BCP 47 language code.",
  #|                "type": "string",
  #|                "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|              }
  #|            },
  #|            "required": ["text", "language"]
  #|          }
  #|        },
  #|        "opening_hours": {
  #|          "description": "Hours and dates of operation for the system in OSM opening_hours format. (added in v3.0)",
  #|          "type": "string"
  #|        },
  #|        "short_name": {
  #|          "description": "Abbreviation for a system. An array with one object per supported language with the following keys:",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "text": {
  #|                "description": "The translated text.",
  #|                "type": "string"
  #|              },
  #|              "language": {
  #|                "description": "IETF BCP 47 language code.",
  #|                "type": "string",
  #|                "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|              }
  #|            },
  #|            "required": ["text", "language"]
  #|          }
  #|        },
  #|        "operator": {
  #|          "description": "Name of the system operator. An array with one object per supported language with the following keys:",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "text": {
  #|                "description": "The translated text.",
  #|                "type": "string"
  #|              },
  #|              "language": {
  #|                "description": "IETF BCP 47 language code.",
  #|                "type": "string",
  #|                "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|              }
  #|            },
  #|            "required": ["text", "language"]
  #|          }
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
  #|        "termination_date": {
  #|          "description": "Date after which this data source will no longer be available to consuming applications.",
  #|          "type": "string",
  #|          "format": "date"
  #|        },
  #|        "phone_number": {
  #|          "description":
  #|            "This OPTIONAL field SHOULD contain a single voice telephone number for the specified system’s customer service department. MUST be in E.164 format as defined in Field Types.",
  #|          "type": "string",
  #|          "pattern": "^\\+[1-9]\\d{1,14}$"
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
  #|        "manifest_url":{
  #|          "description": "REQUIRED if the producer publishes datasets for more than one system geography, for example Berlin and Paris. A fully qualified URL pointing to the manifest.json file for the publisher.",
  #|          "type": "string",
  #|          "format": "uri"
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
  #|        "license_id": {
  #|          "description": "REQUIRED if the dataset is provided under a standard license. An identifier for a standard license from the SPDX License List. Provide license_id rather than license_url if the license is included in the SPDX License List. See the GBFS wiki for a comparison of a subset of standard licenses. If the license_id and license_url fields are blank or omitted, this indicates that the feed is provided under the Creative Commons Universal Public Domain Dedication.",
  #|          "type": "string",
  #|          "enum": [
  #|            "0BSD",
  #|            "AAL",
  #|            "Abstyles",
  #|            "AdaCore-doc",
  #|            "Adobe-2006",
  #|            "Adobe-Glyph",
  #|            "ADSL",
  #|            "AFL-1.1",
  #|            "AFL-1.2",
  #|            "AFL-2.0",
  #|            "AFL-2.1",
  #|            "AFL-3.0",
  #|            "Afmparse",
  #|            "AGPL-1.0-only",
  #|            "AGPL-1.0-or-later",
  #|            "AGPL-3.0-only",
  #|            "AGPL-3.0-or-later",
  #|            "Aladdin",
  #|            "AMDPLPA",
  #|            "AML",
  #|            "AMPAS",
  #|            "ANTLR-PD",
  #|            "ANTLR-PD-fallback",
  #|            "Apache-1.0",
  #|            "Apache-1.1",
  #|            "Apache-2.0",
  #|            "APAFML",
  #|            "APL-1.0",
  #|            "App-s2p",
  #|            "APSL-1.0",
  #|            "APSL-1.1",
  #|            "APSL-1.2",
  #|            "APSL-2.0",
  #|            "Arphic-1999",
  #|            "Artistic-1.0",
  #|            "Artistic-1.0-cl8",
  #|            "Artistic-1.0-Perl",
  #|            "Artistic-2.0",
  #|            "Baekmuk",
  #|            "Bahyph",
  #|            "Barr",
  #|            "Beerware",
  #|            "Bitstream-Charter",
  #|            "Bitstream-Vera",
  #|            "BitTorrent-1.0",
  #|            "BitTorrent-1.1",
  #|            "blessing",
  #|            "BlueOak-1.0.0",
  #|            "Borceux",
  #|            "Brian-Gladman-3-Clause",
  #|            "BSD-1-Clause",
  #|            "BSD-2-Clause",
  #|            "BSD-2-Clause-Patent",
  #|            "BSD-2-Clause-Views",
  #|            "BSD-3-Clause",
  #|            "BSD-3-Clause-Attribution",
  #|            "BSD-3-Clause-Clear",
  #|            "BSD-3-Clause-LBNL",
  #|            "BSD-3-Clause-Modification",
  #|            "BSD-3-Clause-No-Military-License",
  #|            "BSD-3-Clause-No-Nuclear-License",
  #|            "BSD-3-Clause-No-Nuclear-License-2014",
  #|            "BSD-3-Clause-No-Nuclear-Warranty",
  #|            "BSD-3-Clause-Open-MPI",
  #|            "BSD-4-Clause",
  #|            "BSD-4-Clause-Shortened",
  #|            "BSD-4-Clause-UC",
  #|            "BSD-4.3RENO",
  #|            "BSD-4.3TAHOE",
  #|            "BSD-Advertising-Acknowledgement",
  #|            "BSD-Attribution-HPND-disclaimer",
  #|            "BSD-Protection",
  #|            "BSD-Source-Code",
  #|            "BSL-1.0",
  #|            "BUSL-1.1",
  #|            "bzip2-1.0.6",
  #|            "C-UDA-1.0",
  #|            "CAL-1.0",
  #|            "CAL-1.0-Combined-Work-Exception",
  #|            "Caldera",
  #|            "CATOSL-1.1",
  #|            "CC-BY-1.0",
  #|            "CC-BY-2.0",
  #|            "CC-BY-2.5",
  #|            "CC-BY-2.5-AU",
  #|            "CC-BY-3.0",
  #|            "CC-BY-3.0-AT",
  #|            "CC-BY-3.0-DE",
  #|            "CC-BY-3.0-IGO",
  #|            "CC-BY-3.0-NL",
  #|            "CC-BY-3.0-US",
  #|            "CC-BY-4.0",
  #|            "CC-BY-NC-1.0",
  #|            "CC-BY-NC-2.0",
  #|            "CC-BY-NC-2.5",
  #|            "CC-BY-NC-3.0",
  #|            "CC-BY-NC-3.0-DE",
  #|            "CC-BY-NC-4.0",
  #|            "CC-BY-NC-ND-1.0",
  #|            "CC-BY-NC-ND-2.0",
  #|            "CC-BY-NC-ND-2.5",
  #|            "CC-BY-NC-ND-3.0",
  #|            "CC-BY-NC-ND-3.0-DE",
  #|            "CC-BY-NC-ND-3.0-IGO",
  #|            "CC-BY-NC-ND-4.0",
  #|            "CC-BY-NC-SA-1.0",
  #|            "CC-BY-NC-SA-2.0",
  #|            "CC-BY-NC-SA-2.0-DE",
  #|            "CC-BY-NC-SA-2.0-FR",
  #|            "CC-BY-NC-SA-2.0-UK",
  #|            "CC-BY-NC-SA-2.5",
  #|            "CC-BY-NC-SA-3.0",
  #|            "CC-BY-NC-SA-3.0-DE",
  #|            "CC-BY-NC-SA-3.0-IGO",
  #|            "CC-BY-NC-SA-4.0",
  #|            "CC-BY-ND-1.0",
  #|            "CC-BY-ND-2.0",
  #|            "CC-BY-ND-2.5",
  #|            "CC-BY-ND-3.0",
  #|            "CC-BY-ND-3.0-DE",
  #|            "CC-BY-ND-4.0",
  #|            "CC-BY-SA-1.0",
  #|            "CC-BY-SA-2.0",
  #|            "CC-BY-SA-2.0-UK",
  #|            "CC-BY-SA-2.1-JP",
  #|            "CC-BY-SA-2.5",
  #|            "CC-BY-SA-3.0",
  #|            "CC-BY-SA-3.0-AT",
  #|            "CC-BY-SA-3.0-DE",
  #|            "CC-BY-SA-4.0",
  #|            "CC-PDDC",
  #|            "CC0-1.0",
  #|            "CDDL-1.0",
  #|            "CDDL-1.1",
  #|            "CDL-1.0",
  #|            "CDLA-Permissive-1.0",
  #|            "CDLA-Permissive-2.0",
  #|            "CDLA-Sharing-1.0",
  #|            "CECILL-1.0",
  #|            "CECILL-1.1",
  #|            "CECILL-2.0",
  #|            "CECILL-2.1",
  #|            "CECILL-B",
  #|            "CECILL-C",
  #|            "CERN-OHL-1.1",
  #|            "CERN-OHL-1.2",
  #|            "CERN-OHL-P-2.0",
  #|            "CERN-OHL-S-2.0",
  #|            "CERN-OHL-W-2.0",
  #|            "CFITSIO",
  #|            "checkmk",
  #|            "ClArtistic",
  #|            "Clips",
  #|            "CMU-Mach",
  #|            "CNRI-Jython",
  #|            "CNRI-Python",
  #|            "CNRI-Python-GPL-Compatible",
  #|            "COIL-1.0",
  #|            "Community-Spec-1.0",
  #|            "Condor-1.1",
  #|            "copyleft-next-0.3.0",
  #|            "copyleft-next-0.3.1",
  #|            "Cornell-Lossless-JPEG",
  #|            "CPAL-1.0",
  #|            "CPL-1.0",
  #|            "CPOL-1.02",
  #|            "Crossword",
  #|            "CrystalStacker",
  #|            "CUA-OPL-1.0",
  #|            "Cube",
  #|            "curl",
  #|            "D-FSL-1.0",
  #|            "diffmark",
  #|            "DL-DE-BY-2.0",
  #|            "DL-DE-ZERO-2.0",
  #|            "DOC",
  #|            "Dotseqn",
  #|            "DRL-1.0",
  #|            "DSDP",
  #|            "dvipdfm",
  #|            "ECL-1.0",
  #|            "ECL-2.0",
  #|            "EFL-1.0",
  #|            "EFL-2.0",
  #|            "eGenix",
  #|            "Elastic-2.0",
  #|            "Entessa",
  #|            "EPICS",
  #|            "EPL-1.0",
  #|            "EPL-2.0",
  #|            "ErlPL-1.1",
  #|            "etalab-2.0",
  #|            "EUDatagrid",
  #|            "EUPL-1.0",
  #|            "EUPL-1.1",
  #|            "EUPL-1.2",
  #|            "Eurosym",
  #|            "Fair",
  #|            "FDK-AAC",
  #|            "Frameworx-1.0",
  #|            "FreeBSD-DOC",
  #|            "FreeImage",
  #|            "FSFAP",
  #|            "FSFUL",
  #|            "FSFULLR",
  #|            "FSFULLRWD",
  #|            "FTL",
  #|            "GD",
  #|            "GFDL-1.1-invariants-only",
  #|            "GFDL-1.1-invariants-or-later",
  #|            "GFDL-1.1-no-invariants-only",
  #|            "GFDL-1.1-no-invariants-or-later",
  #|            "GFDL-1.1-only",
  #|            "GFDL-1.1-or-later",
  #|            "GFDL-1.2-invariants-only",
  #|            "GFDL-1.2-invariants-or-later",
  #|            "GFDL-1.2-no-invariants-only",
  #|            "GFDL-1.2-no-invariants-or-later",
  #|            "GFDL-1.2-only",
  #|            "GFDL-1.2-or-later",
  #|            "GFDL-1.3-invariants-only",
  #|            "GFDL-1.3-invariants-or-later",
  #|            "GFDL-1.3-no-invariants-only",
  #|            "GFDL-1.3-no-invariants-or-later",
  #|            "GFDL-1.3-only",
  #|            "GFDL-1.3-or-later",
  #|            "Giftware",
  #|            "GL2PS",
  #|            "Glide",
  #|            "Glulxe",
  #|            "GLWTPL",
  #|            "gnuplot",
  #|            "GPL-1.0-only",
  #|            "GPL-1.0-or-later",
  #|            "GPL-2.0-only",
  #|            "GPL-2.0-or-later",
  #|            "GPL-3.0-only",
  #|            "GPL-3.0-or-later",
  #|            "Graphics-Gems",
  #|            "gSOAP-1.3b",
  #|            "HaskellReport",
  #|            "Hippocratic-2.1",
  #|            "HP-1986",
  #|            "HPND",
  #|            "HPND-export-US",
  #|            "HPND-Markus-Kuhn",
  #|            "HPND-sell-variant",
  #|            "HPND-sell-variant-MIT-disclaimer",
  #|            "HTMLTIDY",
  #|            "IBM-pibs",
  #|            "ICU",
  #|            "IEC-Code-Components-EULA",
  #|            "IJG",
  #|            "IJG-short",
  #|            "ImageMagick",
  #|            "iMatix",
  #|            "Imlib2",
  #|            "Info-ZIP",
  #|            "Intel",
  #|            "Intel-ACPI",
  #|            "Interbase-1.0",
  #|            "IPA",
  #|            "IPL-1.0",
  #|            "ISC",
  #|            "Jam",
  #|            "JasPer-2.0",
  #|            "JPL-image",
  #|            "JPNIC",
  #|            "JSON",
  #|            "Kazlib",
  #|            "Knuth-CTAN",
  #|            "LAL-1.2",
  #|            "LAL-1.3",
  #|            "Latex2e",
  #|            "Leptonica",
  #|            "LGPL-2.0-only",
  #|            "LGPL-2.0-or-later",
  #|            "LGPL-2.1-only",
  #|            "LGPL-2.1-or-later",
  #|            "LGPL-3.0-only",
  #|            "LGPL-3.0-or-later",
  #|            "LGPLLR",
  #|            "Libpng",
  #|            "libpng-2.0",
  #|            "libselinux-1.0",
  #|            "libtiff",
  #|            "libutil-David-Nugent",
  #|            "LiLiQ-P-1.1",
  #|            "LiLiQ-R-1.1",
  #|            "LiLiQ-Rplus-1.1",
  #|            "Linux-man-pages-copyleft",
  #|            "Linux-OpenIB",
  #|            "LOOP",
  #|            "LPL-1.0",
  #|            "LPL-1.02",
  #|            "LPPL-1.0",
  #|            "LPPL-1.1",
  #|            "LPPL-1.2",
  #|            "LPPL-1.3a",
  #|            "LPPL-1.3c",
  #|            "LZMA-SDK-9.11-to-9.20",
  #|            "LZMA-SDK-9.22",
  #|            "MakeIndex",
  #|            "Martin-Birgmeier",
  #|            "Minpack",
  #|            "MirOS",
  #|            "MIT",
  #|            "MIT-0",
  #|            "MIT-advertising",
  #|            "MIT-CMU",
  #|            "MIT-enna",
  #|            "MIT-feh",
  #|            "MIT-Modern-Variant",
  #|            "MIT-open-group",
  #|            "MIT-Wu",
  #|            "MITNFA",
  #|            "Motosoto",
  #|            "mpi-permissive",
  #|            "mpich2",
  #|            "MPL-1.0",
  #|            "MPL-1.1",
  #|            "MPL-2.0",
  #|            "MPL-2.0-no-copyleft-exception",
  #|            "mplus",
  #|            "MS-LPL",
  #|            "MS-PL",
  #|            "MS-RL",
  #|            "MTLL",
  #|            "MulanPSL-1.0",
  #|            "MulanPSL-2.0",
  #|            "Multics",
  #|            "Mup",
  #|            "NAIST-2003",
  #|            "NASA-1.3",
  #|            "Naumen",
  #|            "NBPL-1.0",
  #|            "NCGL-UK-2.0",
  #|            "NCSA",
  #|            "Net-SNMP",
  #|            "NetCDF",
  #|            "Newsletr",
  #|            "NGPL",
  #|            "NICTA-1.0",
  #|            "NIST-PD",
  #|            "NIST-PD-fallback",
  #|            "NLOD-1.0",
  #|            "NLOD-2.0",
  #|            "NLPL",
  #|            "Nokia",
  #|            "NOSL",
  #|            "Noweb",
  #|            "NPL-1.0",
  #|            "NPL-1.1",
  #|            "NPOSL-3.0",
  #|            "NRL",
  #|            "NTP",
  #|            "NTP-0",
  #|            "O-UDA-1.0",
  #|            "OCCT-PL",
  #|            "OCLC-2.0",
  #|            "ODbL-1.0",
  #|            "ODC-By-1.0",
  #|            "OFFIS",
  #|            "OFL-1.0",
  #|            "OFL-1.0-no-RFN",
  #|            "OFL-1.0-RFN",
  #|            "OFL-1.1",
  #|            "OFL-1.1-no-RFN",
  #|            "OFL-1.1-RFN",
  #|            "OGC-1.0",
  #|            "OGDL-Taiwan-1.0",
  #|            "OGL-Canada-2.0",
  #|            "OGL-UK-1.0",
  #|            "OGL-UK-2.0",
  #|            "OGL-UK-3.0",
  #|            "OGTSL",
  #|            "OLDAP-1.1",
  #|            "OLDAP-1.2",
  #|            "OLDAP-1.3",
  #|            "OLDAP-1.4",
  #|            "OLDAP-2.0",
  #|            "OLDAP-2.0.1",
  #|            "OLDAP-2.1",
  #|            "OLDAP-2.2",
  #|            "OLDAP-2.2.1",
  #|            "OLDAP-2.2.2",
  #|            "OLDAP-2.3",
  #|            "OLDAP-2.4",
  #|            "OLDAP-2.5",
  #|            "OLDAP-2.6",
  #|            "OLDAP-2.7",
  #|            "OLDAP-2.8",
  #|            "OML",
  #|            "OpenPBS-2.3",
  #|            "OpenSSL",
  #|            "OPL-1.0",
  #|            "OPUBL-1.0",
  #|            "OSET-PL-2.1",
  #|            "OSL-1.0",
  #|            "OSL-1.1",
  #|            "OSL-2.0",
  #|            "OSL-2.1",
  #|            "OSL-3.0",
  #|            "Parity-6.0.0",
  #|            "Parity-7.0.0",
  #|            "PDDL-1.0",
  #|            "PHP-3.0",
  #|            "PHP-3.01",
  #|            "Plexus",
  #|            "PolyForm-Noncommercial-1.0.0",
  #|            "PolyForm-Small-Business-1.0.0",
  #|            "PostgreSQL",
  #|            "PSF-2.0",
  #|            "psfrag",
  #|            "psutils",
  #|            "Python-2.0",
  #|            "Python-2.0.1",
  #|            "Qhull",
  #|            "QPL-1.0",
  #|            "QPL-1.0-INRIA-2004",
  #|            "Rdisc",
  #|            "RHeCos-1.1",
  #|            "RPL-1.1",
  #|            "RPL-1.5",
  #|            "RPSL-1.0",
  #|            "RSA-MD",
  #|            "RSCPL",
  #|            "Ruby",
  #|            "SAX-PD",
  #|            "Saxpath",
  #|            "SCEA",
  #|            "SchemeReport",
  #|            "Sendmail",
  #|            "Sendmail-8.23",
  #|            "SGI-B-1.0",
  #|            "SGI-B-1.1",
  #|            "SGI-B-2.0",
  #|            "SHL-0.5",
  #|            "SHL-0.51",
  #|            "SimPL-2.0",
  #|            "SISSL",
  #|            "SISSL-1.2",
  #|            "Sleepycat",
  #|            "SMLNJ",
  #|            "SMPPL",
  #|            "SNIA",
  #|            "snprintf",
  #|            "Spencer-86",
  #|            "Spencer-94",
  #|            "Spencer-99",
  #|            "SPL-1.0",
  #|            "SSH-OpenSSH",
  #|            "SSH-short",
  #|            "SSPL-1.0",
  #|            "SugarCRM-1.1.3",
  #|            "SunPro",
  #|            "SWL",
  #|            "Symlinks",
  #|            "TAPR-OHL-1.0",
  #|            "TCL",
  #|            "TCP-wrappers",
  #|            "TMate",
  #|            "TORQUE-1.1",
  #|            "TOSL",
  #|            "TPDL",
  #|            "TPL-1.0",
  #|            "TTWL",
  #|            "TU-Berlin-1.0",
  #|            "TU-Berlin-2.0",
  #|            "UCAR",
  #|            "UCL-1.0",
  #|            "Unicode-DFS-2015",
  #|            "Unicode-DFS-2016",
  #|            "Unicode-TOU",
  #|            "Unlicense",
  #|            "UPL-1.0",
  #|            "Vim",
  #|            "VOSTROM",
  #|            "VSL-1.0",
  #|            "W3C",
  #|            "W3C-19980720",
  #|            "W3C-20150513",
  #|            "w3m",
  #|            "Watcom-1.0",
  #|            "Wsuipa",
  #|            "WTFPL",
  #|            "X11",
  #|            "X11-distribute-modifications-variant",
  #|            "Xerox",
  #|            "XFree86-1.1",
  #|            "xinetd",
  #|            "xlock",
  #|            "Xnet",
  #|            "xpp",
  #|            "XSkat",
  #|            "YPL-1.0",
  #|            "YPL-1.1",
  #|            "Zed",
  #|            "Zend-2.0",
  #|            "Zimbra-1.3",
  #|            "Zimbra-1.4",
  #|            "Zlib",
  #|            "zlib-acknowledgement",
  #|            "ZPL-1.1",
  #|            "ZPL-2.0",
  #|            "ZPL-2.1"
  #|          ]
  #|        },
  #|        "license_url": {
  #|          "description":
  #|            "A fully qualified URL of a page that defines the license terms for the GBFS data for this system.",
  #|          "type": "string",
  #|          "format": "uri"
  #|        },
  #|        "attribution_organization_name": {
  #|          "description": "If the feed license requires attribution, name of the organization to which attribution should be provided. An array with one object per supported language with the following keys:",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "text": {
  #|                "description": "The translated text.",
  #|                "type": "string"
  #|              },
  #|              "language": {
  #|                "description": "IETF BCP 47 language code.",
  #|                "type": "string",
  #|                "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|              }
  #|            },
  #|            "required": ["text", "language"]
  #|          }
  #|        },
  #|        "attribution_url": {
  #|          "description": "URL of the organization to which attribution should be provided.",
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
  #|          "A fully qualified URL pointing to the terms of service (also often called \"terms of use\" or \"terms and conditions\") for the service. An array with one object per supported language with the following keys:",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "text": {
  #|                "description": "The translated text.",
  #|                "type": "string",
  #|                "format": "uri"
  #|              },
  #|              "language": {
  #|                "description": "IETF BCP 47 language code.",
  #|                "type": "string",
  #|                "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|              }
  #|            },
  #|            "required": ["text", "language"]
  #|          }
  #|        },
  #|        "terms_last_updated": {
  #|          "description":
  #|          "The date that the terms of service provided at terms_url were last updated (added in v2.3-RC)",
  #|          "type": "string",
  #|          "format": "date"
  #|        },
  #|        "privacy_url": {
  #|          "description":
  #|          "A fully qualified URL pointing to the privacy policy for the service. An array with one object per supported language with the following keys:",
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "text": {
  #|                "description": "The translated text.",
  #|                "type": "string",
  #|                "format": "uri"
  #|              },
  #|              "language": {
  #|                "description": "IETF BCP 47 language code.",
  #|                "type": "string",
  #|                "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|              }
  #|            },
  #|            "required": ["text", "language"]
  #|          }
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
  #|      "oneOf": [
  #|        {
  #|          "not": {"required" : ["license_url", "license_id"] }
  #|        },
  #|        {
  #|          "required": ["license_id"],
  #|          "not": {"required": ["license_id"] }
  #|        },
  #|        {
  #|          "required": ["license_url"],
  #|          "not": {"required": ["license_url"] }
  #|        }
  #|      ],
  #|      "required": ["system_id", "languages", "name", "opening_hours", "feed_contact_email", "timezone"],
  #|      "dependencies": {
  #|        "terms_url": ["terms_last_updated"],
  #|        "privacy_url": ["privacy_last_updated"]
  #|      },
  #|      "additionalProperties": false
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}

///|
let schema_station_information : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v3.0/gbfs.md#station_informationjson",
  #|  "description":
  #|    "List of all stations, their capacities and locations. REQUIRED of systems utilizing docks.",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in RFC3339 format.",
  #|      "type": "string",
  #|      "format": "date-time"
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
  #|      "const": "3.0"
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
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "text": {
  #|                      "description": "The translated text.",
  #|                      "type": "string"
  #|                    },
  #|                    "language": {
  #|                      "description": "IETF BCP 47 language code.",
  #|                      "type": "string",
  #|                      "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|                    }
  #|                  },
  #|                  "required": ["text", "language"]
  #|                }
  #|              },
  #|              "short_name": {
  #|                "description": "Short name or other type of identifier.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "text": {
  #|                      "description": "The translated text.",
  #|                      "type": "string"
  #|                    },
  #|                    "language": {
  #|                      "description": "IETF BCP 47 language code.",
  #|                      "type": "string",
  #|                      "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|                    }
  #|                  },
  #|                  "required": ["text", "language"]
  #|                }
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
  #|              "station_opening_hours": {
  #|                "description": "Hours of operation for the station in OSM opening_hours format.",
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
  #|              "vehicle_types_capacity": {
  #|                "description": "This field's value is an array of objects containing the keys vehicle_type_ids and count defined below. These objects are used to model the parking capacity of virtual stations (defined using the is_virtual_station field) for each vehicle type that can be returned to this station.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "vehicle_type_ids": {
  #|                      "description": "The vehicle_type_ids, as defined in vehicle_types.json, that may park at the virtual station.",
  #|                      "type": "array",
  #|                      "items": {
  #|                        "type": "string"
  #|                      }
  #|                    },
  #|                    "count": {
  #|                      "description": "A number representing the total number of vehicles of the specified vehicle_type_ids that can park within the virtual station.",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    }
  #|                  },
  #|                  "required": ["vehicle_type_ids","count"]
  #|                }
  #|              },
  #|              "vehicle_docks_capacity": {
  #|                "description": "This field's value is an array of objects containing the keys vehicle_type_ids and count defined below. These objects are used to model the total docking capacity of a station, both available and unavailable, for each type of vehicle that may dock at this station.",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "vehicle_type_ids": {
  #|                      "description": "An array of strings where each string represents a vehicle_type_id that is able to use a particular type of dock at the station.",
  #|                      "type": "array",
  #|                      "items": {
  #|                        "type": "string"
  #|                      }
  #|                    },
  #|                    "count": {
  #|                      "description": "A number representing the total number of docks at the station, both available and unavailable, that may accept the vehicle types specified by vehicle_type_ids.",
  #|                      "type": "integer",
  #|                      "minimum": 0
  #|                    }
  #|                  },
  #|                  "required": ["vehicle_type_ids","count"]
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
let schema_station_status : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id": "https://github.com/MobilityData/gbfs/blob/v3.0/gbfs.md#station_statusjson",
  #|  "description":
  #|    "Describes the capacity and rental availability of the station",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in RFC3339 format.",
  #|      "type": "string",
  #|      "format": "date-time"
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
  #|      "const": "3.0"
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
  #|              "num_vehicles_available": {
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
  #|              "num_vehicles_disabled": {
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
  #|                  "The last time this station reported its status to the operator's backend in RFC3339 format.",
  #|                "type": "string",
  #|                "format": "date-time"
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
  #|              "num_vehicles_available",
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
let schema_vehicle_types : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v3.0/gbfs.md#vehicle_typesjson",
  #|  "description":
  #|    "Describes the types of vehicles that System operator has available for rent (added in v2.1-RC).",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in RFC3339 format.",
  #|      "type": "string",
  #|      "format": "date-time"
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
  #|      "const": "3.0"
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
  #|                "enum": ["bicycle", "cargo_bicycle" ,"car", "moped", "scooter_standing", "scooter_seated", "other"]
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
  #|              "eco_labels": {
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
  #|                "description": "The public name of this vehicle type. An array with one object per supported language with the following keys:",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "text": {
  #|                      "description": "The translated text.",
  #|                      "type": "string"
  #|                    },
  #|                    "language": {
  #|                      "description": "IETF BCP 47 language code.",
  #|                      "type": "string",
  #|                      "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|                    }
  #|                  },
  #|                  "required": ["text", "language"]
  #|                }
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
  #|                "description": "The name of the vehicle manufacturer. An array with one object per supported language with the following keys:",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "text": {
  #|                      "description": "The translated text.",
  #|                      "type": "string"
  #|                    },
  #|                    "language": {
  #|                      "description": "IETF BCP 47 language code.",
  #|                      "type": "string",
  #|                      "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|                    }
  #|                  },
  #|                  "required": ["text", "language"]
  #|                }
  #|              },
  #|              "model": {
  #|                "description": "The name of the vehicle model. An array with one object per supported language with the following keys:",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "text": {
  #|                      "description": "The translated text.",
  #|                      "type": "string"
  #|                    },
  #|                    "language": {
  #|                      "description": "IETF BCP 47 language code.",
  #|                      "type": "string",
  #|                      "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|                    }
  #|                  },
  #|                  "required": ["text", "language"]
  #|                }
  #|              },
  #|              "color": {
  #|                "description": "The color of the vehicle. Added in v2.3",
  #|                "type": "string"
  #|              },
  #|              "description": {
  #|                "description": "Customer-readable description of the vehicle type outlining special features or how-tos. An array with one object per supported language with the following keys:",
  #|                "type": "array",
  #|                "items": {
  #|                  "type": "object",
  #|                  "properties": {
  #|                    "text": {
  #|                      "description": "The translated text.",
  #|                      "type": "string"
  #|                    },
  #|                    "language": {
  #|                      "description": "IETF BCP 47 language code.",
  #|                      "type": "string",
  #|                      "pattern": "^[a-z]{2,3}(-[A-Z]{2})?$"
  #|                    }
  #|                  },
  #|                  "required": ["text", "language"]
  #|                }
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
let schema_vehicle_status : String =
  #|{
  #|  "$schema": "http://json-schema.org/draft-07/schema",
  #|  "$id":
  #|    "https://github.com/MobilityData/gbfs/blob/v3.0/gbfs.md#vehicle_statusjson",
  #|  "description":
  #|    "Describes the vehicles that are available for rent (as of v3.0, formerly free_bike_status).",
  #|  "type": "object",
  #|  "properties": {
  #|    "last_updated": {
  #|      "description":
  #|        "Last time the data in the feed was updated in RFC3339 format.",
  #|      "type": "string",
  #|      "format": "date-time"
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
  #|      "const": "3.0"
  #|    },
  #|    "data": {
  #|      "description":
  #|        "Array that contains one object per vehicle as defined below.",
  #|      "type": "object",
  #|      "properties": {
  #|        "vehicles": {
  #|          "type": "array",
  #|          "items": {
  #|            "type": "object",
  #|            "properties": {
  #|              "vehicle_id": {
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
  #|                "description": "The last time this vehicle reported its status to the operator's backend in RFC3339 format (added in v2.1-RC).",
  #|                "type": "string",
  #|                "format": "date-time"
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
  #|            "required": ["vehicle_id", "is_reserved", "is_disabled"]
  #|          }
  #|        }
  #|      },
  #|      "required": ["vehicles"]
  #|    }
  #|  },
  #|  "required": ["last_updated", "ttl", "version", "data"]
  #|}
