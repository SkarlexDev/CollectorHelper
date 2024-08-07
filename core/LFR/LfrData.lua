local _, app = ...
local COLORS = app.COLORS


local lfrData = {
    -- Cata
    [967] = {
        name = "Dragon Soul",
        wings = {
            [1] = {
                name = "Siege of Wyrmrest Temple",
                bosses = {
                    { bossName = "Morchok",                 index = 1 },
                    { bossName = "Warlord Zon'ozz",         index = 2 },
                    { bossName = "Yor'sahj the Unsleeping", index = 3 },
                    { bossName = "Hagara",                  index = 4 }
                }
            },
            [2] = {
                name = "Fall of Deathwing",
                bosses = {
                    { bossName = "Ultraxion",            index = 5 },
                    { bossName = "Warmaster Blackhorn",  index = 6 },
                    { bossName = "Spine of Deathwing",   index = 7 },
                    { bossName = "Madness of Deathwing", index = 8 }
                }
            }
        }
    },
    -- Pandaria
    [1008] = {
        name = "Mogu'shan Vaults",
        wings = {
            [1] = {
                name = "Guardians of Mogu'shan",
                bosses = {
                    { bossName = "The Stone Guard",           index = 1 },
                    { bossName = "Feng the Accursed",         index = 2 },
                    { bossName = "Gara'jal the Spiritbinder", index = 3 }
                }
            },
            [2] = {
                name = "The Vault of Mysteries",
                bosses = {
                    { bossName = "The Spirit Kings",    index = 4 },
                    { bossName = "Elegon",              index = 5 },
                    { bossName = "Will of the Emperor", index = 6 }
                }
            }

        }
    },
    [1009] = {
        name = "Heart of Fear",
        wings = {
            [1] = {
                name = "The Dread Approach",
                bosses = {
                    { bossName = "Imperial Vizier Zor'lok", index = 1 },
                    { bossName = "Blade Lord Ta'yak",       index = 2 },
                    { bossName = "Garalon",                 index = 3 }
                }
            },
            [2] = {
                name = "Nightmare of Shek'zeer",
                bosses = {
                    { bossName = "Wind Lord Mel'jarak",     index = 4 },
                    { bossName = "Amber-Shaper Un'sok",     index = 5 },
                    { bossName = "Grand Empress Shek'zeer", index = 6 }
                }
            }
        }
    },
    [996] = {
        name = "Terrace of Endless Spring",
        wings = {
            [1] = {
                name = "Terrace of Endless Spring",
                bosses = {
                    { bossName = "Protectors of the Endless", index = 1 },
                    { bossName = "Tsulong",                   index = 2 },
                    { bossName = "Lei Shi",                   index = 3 },
                    { bossName = "Sha of Fear",               index = 4 }
                }
            }
        }
    },
    [1098] = {
        name = "Throne of Thunder",
        wings = {
            [1] = {
                name = "Last Stand of the Zandalari",
                bosses = {
                    { bossName = "Jin'rokh the Breaker", index = 1 },
                    { bossName = "Horridon",             index = 2 },
                    { bossName = "Council of Elders",    index = 3 }
                }
            },
            [2] = {
                name = "Forgotten Depths",
                bosses = {
                    { bossName = "Tortos",  index = 4 },
                    { bossName = "Megaera", index = 5 },
                    { bossName = "Ji-Kun",  index = 6 }
                }
            },
            [3] = {
                name = "Halls of Flesh-Shaping",
                bosses = {
                    { bossName = "Durumu the Forgotten", index = 7 },
                    { bossName = "Primordius",           index = 8 },
                    { bossName = "Dark Animus",          index = 9 }
                }
            },
            [4] = {
                name = "Pinnacle of Storms",
                bosses = {
                    { bossName = "Iron Qon",       index = 10 },
                    { bossName = "Twin Empyreans", index = 11 },
                    { bossName = "Lei Shen",       index = 12 }
                }
            }
        }
    },
    [1136] = {
        name = "Siege of Orgrimmar",
        wings = {
            [1] = {
                name = "Vale of Eternal Sorrows",
                bosses = {
                    { bossName = "Immerseus",             index = 1 },
                    { bossName = "The Fallen Protectors", index = 2 },
                    { bossName = "Norushen",              index = 3 },
                    { bossName = "Sha of Pride",          index = 4 }
                }
            },
            [2] = {
                name = "Gates of Retribution",
                bosses = {
                    { bossName = "Galakras",             index = 5 },
                    { bossName = "Iron Juggernaut",      index = 6 },
                    { bossName = "Kor'kron Dark Shaman", index = 7 },
                    { bossName = "General Nazgrim",      index = 8 }
                }
            },
            [3] = {
                name = "The Underhold",
                bosses = {
                    { bossName = "Malkorok",              index = 9 },
                    { bossName = "Spoils of Pandaria",    index = 10 },
                    { bossName = "Thok the Bloodthirsty", index = 11 }
                }
            },
            [4] = {
                name = "Downfall",
                bosses = {
                    { bossName = "Siegecrafter Blackfuse", index = 12 },
                    { bossName = "Paragons of the Klaxxi", index = 13 },
                    { bossName = "Garrosh Hellscream",     index = 14 }
                }
            }
        }
    },
    -- Draenor
    [1228] = {
        name = "Highmaul",
        wings = {
            [1] = {
                name = "Walled City",
                bosses = {
                    { bossName = "Kargath Bladefist", index = 1 },
                    { bossName = "The Butcher",       index = 2 },
                    { bossName = "Brackenspore",      index = 3 }
                }
            },
            [2] = {
                name = "Arcane Sanctum",
                bosses = {
                    { bossName = "Tectus, The Living Mountain", index = 4 },
                    { bossName = "Twin Ogron",                  index = 5 },
                    { bossName = "Ko'ragh",                     index = 6 }
                }
            },
            [3] = {
                name = "Imperator's Rise",
                bosses = {
                    { bossName = "Imperator Mar'gok", index = 7 }
                }
            }
        }
    },
    [1205] = {
        name = "Blackrock Foundry",
        wings = {
            [1] = {
                name = "Slagworks",
                bosses = {
                    { bossName = "Oregorger the Devourer", index = 1 },
                    { bossName = "Gruul",                  index = 2 },
                    { bossName = "Blast Furnace",          index = 7 }
                }
            },
            [2] = {
                name = "The Black Forge",
                bosses = {
                    { bossName = "Hans'gar & Franzok",             index = 3 },
                    { bossName = "Flamebender Ka'graz",            index = 5 },
                    { bossName = "Kromog, Legend of the Mountain", index = 8 }
                }
            },
            [3] = {
                name = "Iron Assembly",
                bosses = {
                    { bossName = "Beastlord Darmac",  index = 4 },
                    { bossName = "Operator Thogar",   index = 6 },
                    { bossName = "The Iron Maidens ", index = 9 }
                }
            },
            [4] = {
                name = "Blackhand's Crucible",
                bosses = {
                    { bossName = "Blackhand", index = 10 }
                }
            }
        }
    },
    [1448] = {
        name = "Hellfire Citadel",
        wings = {
            [1] = {
                name = "Hellfire Citadel",
                bosses = {
                    { bossName = "Hellfire Assault", index = 1 },
                    { bossName = "Iron Reaver",      index = 2 },
                    { bossName = "Kormrok",          index = 3 }
                }
            },
            [2] = {
                name = "Halls of Blood",
                bosses = {
                    { bossName = "Hellfire High Council", index = 4 },
                    { bossName = "Kilrogg Deadeye",       index = 5 },
                    { bossName = "Gorefiend",             index = 6 }
                }
            },
            [3] = {
                name = "Bastion of Shadows",
                bosses = {
                    { bossName = "Shadow-Lord Iskar",     index = 7 },
                    { bossName = "Socrethar the Eternal", index = 8 },
                    { bossName = "Tyrant Velhari",        index = 11 }
                }
            },
            [4] = {
                name = "Destructor's Rise",
                bosses = {
                    { bossName = "Fel Lord Zakuun", index = 9 },
                    { bossName = "Xhul'horac",      index = 10 },
                    { bossName = "Mannoroth",       index = 12 }
                }
            },
            [5] = {
                name = "Archimonde's fall",
                bosses = {
                    { bossName = "Archimonde", index = 13 }
                }
            },

        }
    },
    -- Legion
    [1520] = {
        name = "The Emerald Nightmare",
        wings = {
            [1] = {
                name = "Darkbough",
                bosses = {
                    { bossName = "Nythendra",                          index = 1 },
                    { bossName = "Elerethe Renferal",                  index = 5 },
                    { bossName = "Il'gynoth, The Heart of Corruption", index = 3 }
                }
            },
            [2] = {
                name = "Tormented Guardians",
                bosses = {
                    { bossName = "Ursoc",                index = 2 },
                    { bossName = "Dragons of Nightmare", index = 4 },
                    { bossName = "Cenarius",             index = 6 }
                }
            },
            [3] = {
                name = "Rift of Aln",
                bosses = {
                    { bossName = "Xavius", index = 7 }
                }
            },
        }
    },
    [1530] = {
        name = "The Nighthold",
        wings = {
            [1] = {
                name = "Arcing Aqueducts",
                bosses = {
                    { bossName = "Skorpyron",           index = 1 },
                    { bossName = "Chronomatic Anomaly", index = 2 },
                    { bossName = "Trilliax",            index = 3 }
                }
            },
            [2] = {
                name = "Royal Athenaeum",
                bosses = {
                    { bossName = "Spellblade Aluriel",    index = 4 },
                    { bossName = "Star Augur Etraeus",    index = 8 },
                    { bossName = "High Botanist Tel'arn", index = 6 }
                }
            },
            [3] = {
                name = "Nightspire",
                bosses = {
                    { bossName = "Tichondrius",              index = 5 },
                    { bossName = "Krosus",                   index = 7 },
                    { bossName = "Grand Magistrix Elisande", index = 9 }
                }
            },
            [4] = {
                name = "Betrayer's Rise",
                bosses = {
                    { bossName = "Gul'dan", index = 10 }
                }
            }
        }
    },
    [1648] = {
        name = "Trial of Valor",
        wings = {
            [1] = {
                name = "Trial of Valor",
                bosses = {
                    { bossName = "Odyn",  index = 1 },
                    { bossName = "Guarm", index = 2 },
                    { bossName = "Helya", index = 3 }
                }
            }
        }
    },
    [1676] = {
        name = "Tomb of Sargeras",
        wings = {
            [1] = {
                name = "The Gates of Hell",
                bosses = {
                    { bossName = "Goroth",             index = 1 },
                    { bossName = "Harjatan",           index = 3 },
                    { bossName = "Mistress Sassz'ine", index = 5 }
                }
            },
            [2] = {
                name = "Wailing Halls",
                bosses = {
                    { bossName = "Demonic Inquisition", index = 2 },
                    { bossName = "Sisters of the Moon", index = 4 },
                    { bossName = "The Desolate Host",   index = 6 }
                }
            },
            [3] = {
                name = "Chamber of the Avatar",
                bosses = {
                    { bossName = "Maiden of Vigilance", index = 7 },
                    { bossName = "Fallen Avatar",       index = 8 }
                }
            },
            [4] = {
                name = "Deceiver's Fall",
                bosses = {
                    { bossName = "Kil'jaeden", index = 9 }
                }
            },
        }
    },
    [1712] = {
        name = "Antorus, the Burning Throne",
        wings = {
            [1] = {
                name = "Light's Breach",
                bosses = {
                    { bossName = "Garothi Worldbreaker",  index = 1 },
                    { bossName = "Felhounds of Sargeras", index = 2 },
                    { bossName = "Antoran High Command",  index = 4 }
                }
            },
            [2] = {
                name = "Forbidden Descent",
                bosses = {
                    { bossName = "The Defense of Eonar",  index = 5 },
                    { bossName = "Portal Keeper Hasabel", index = 3 },
                    { bossName = "Imonar the Soulhunter", index = 6 }
                }
            },
            [3] = {
                name = "Hope's End",
                bosses = {
                    { bossName = "Kin'garoth",            index = 7 },
                    { bossName = "Varimathras",           index = 8 },
                    { bossName = "The Coven of Shivarra", index = 9 }
                }
            },
            [4] = {
                name = "Seat of the Pantheon",
                bosses = {
                    { bossName = "Aggramar",          index = 10 },
                    { bossName = "Argus the Unmaker", index = 11 }
                }
            }

        }
    },
    -- BFA
    [1861] = {
        name = "Uldir",
        wings = {
            [1] = {
                name = "Halls of Containment",
                bosses = {
                    { bossName = "Taloc",   index = 1 },
                    { bossName = "MOTHER",  index = 2 },
                    { bossName = "Zek'voz", index = 3 }
                }
            },
            [2] = {
                name = "Crimson Descent",
                bosses = {
                    { bossName = "Fetid Devourer ", index = 4 },
                    { bossName = "Vectis",          index = 5 },
                    { bossName = "Zul",             index = 6 }
                }
            },
            [3] = {
                name = "Heart of Corruption",
                bosses = {
                    { bossName = "Mythrax the Unraveler", index = 7 },
                    { bossName = "G'huun",                index = 8 }
                }
            }
        }
    },
    [2070] = {
        name = "Battle of Dazar'alor",
        wings = {
            [1] = {
                name = "Siege of Dazar'alor",
                bosses = {
                    { bossName = "Champion of the Light", index = 1 },
                    { bossName = "Jadefire Masters",      index = 2 },
                    { bossName = "Grong the Revenant",    index = 3 }
                }
            },
            [2] = {
                name = "Empire's Fall",
                bosses = {
                    { bossName = "Opulence",               index = 4 },
                    { bossName = "Conclave of the Chosen", index = 5 },
                    { bossName = "King Rastakhan",         index = 6 }
                }
            },
            [3] = {
                name = "Might of the Alliance",
                bosses = {
                    { bossName = "Mekkatorque",           index = 7 },
                    { bossName = "Stormwall Blockade",    index = 8 },
                    { bossName = "Lady Jaina Proudmoore", index = 9 }
                }
            }
        }
    },
    [2096] = {
        name = "Crucible of Storms",
        wings = {
            [1] = {
                name = "Crucible of Storms ",
                bosses = {
                    { bossName = "The Restless Cabal",            index = 1 },
                    { bossName = "Uu'nat, Harbinger of the Void", index = 2 }
                }
            }
        }
    },
    [2164] = {
        name = "The Eternal Palace",
        wings = {
            [1] = {
                name = "The Grand Reception",
                bosses = {
                    { bossName = "Abyssal Commander Sivara", index = 1 },
                    { bossName = "Blackwater Behemoth",      index = 3 },
                    { bossName = "Radiance of Azshara",      index = 2 }
                }
            },
            [2] = {
                name = "Depths of the Devoted",
                bosses = {
                    { bossName = "Lady Ashvane",      index = 4 },
                    { bossName = "Orgozoa",           index = 5 },
                    { bossName = "The Queen's Court", index = 6 }
                }
            },
            [3] = {
                name = "The Circle of Stars",
                bosses = {
                    { bossName = "Za'qul",        index = 7 },
                    { bossName = "Queen Azshara", index = 8 }
                }
            }
        }
    },
    [2217] = {
        name = "Ny'alotha, the Waking City",
        wings = {
            [1] = {
                name = "Vision of Destiny",
                bosses = {
                    { bossName = "Wrathion",       index = 1 },
                    { bossName = "Maut",           index = 3 },
                    { bossName = "Prophet Skitra", index = 2 }
                }
            },
            [2] = {
                name = "Halls of Devotion",
                bosses = {
                    { bossName = "Dark Inquisitor Xanesh", index = 4 },
                    { bossName = "Vexiona",                index = 5 },
                    { bossName = "The Hivemind",           index = 6 },
                    { bossName = "Ra-den the Despoiled",   index = 7 }
                }
            },
            [3] = {
                name = "Gift of Flesh",
                bosses = {
                    { bossName = "Shad'har the Insatiable",      index = 8 },
                    { bossName = "Drest'agath",                  index = 9 },
                    { bossName = "Il'gynoth, Corruption Reborn", index = 10 }
                }
            },
            [4] = {
                name = "The Waking Dream",
                bosses = {
                    { bossName = "Carapace of N'Zoth",   index = 11 },
                    { bossName = "N'Zoth the Corruptor", index = 12 }
                }
            }
        }
    },
    -- Shadowlands
    [2296] = {
        name = "Castle Nathria",
        wings = {
            [1] = {
                name = "Leeching Vaults",
                bosses = {
                    { bossName = "Huntsman Altimor",     index = 2 },
                    { bossName = "Hungering Destroyer",  index = 4 },
                    { bossName = "Lady Inerva Darkvein", index = 6 }
                }
            },
            [2] = {
                name = "Reliquary of Opulence",
                bosses = {
                    { bossName = "Sun King's Salvation ", index = 3 },
                    { bossName = "Artificer Xy'mox",      index = 5 },
                    { bossName = "The Council of Blood",  index = 7 },

                }
            },
            [3] = {
                name = "Blood from Stone",
                bosses = {
                    { bossName = "Shriekwing",            index = 1 },
                    { bossName = "Sludgefist",            index = 8 },
                    { bossName = "Stone Legion Generals", index = 9 }
                }
            },
            [4] = {
                name = "Audience with Arrogance",
                bosses = {
                    { bossName = "Sire Denathrius", index = 10 }
                }
            },
        }
    },
    [2450] = {
        name = "Sanctum of Domination",
        wings = {
            [1] = {
                name = "Jailer's Vanguard",
                bosses = {
                    { bossName = "The Tarragrue",         index = 1 },
                    { bossName = "The Eye of the Jailer", index = 2 },
                    { bossName = "The Nine",              index = 3 }
                }
            },
            [2] = {
                name = "Dark Bastille",
                bosses = {
                    { bossName = "Soulrender Dormazain", index = 4 },
                    { bossName = "Remnant of Ner'zhul",  index = 5 },
                    { bossName = "Painsmith Raznal",     index = 6 }
                }
            },
            [3] = {
                name = "Shackles of Fate",
                bosses = {
                    { bossName = "Guardian of the First Ones", index = 7 },
                    { bossName = "Fatescribe Roh-Kalo",        index = 8 },
                    { bossName = "Kel'Thuzad",                 index = 9 }
                }
            },
            [4] = {
                name = "Reckoning",
                bosses = {
                    { bossName = "Sylvanas Windrunner", index = 10 }
                }
            },
        }
    },
    [2481] = {
        name = "Sepulcher of the First Ones",
        wings = {
            [1] = {
                name = "Ephemeral Plains",
                bosses = {
                    { bossName = "Vigilant Guardian",              index = 1 },
                    { bossName = "Skolex, the Insatiable Ravener", index = 5 },
                    { bossName = "Artificer Xy'mox",               index = 3 },
                    { bossName = "Halondrus the Reclaimer",        index = 6 }
                }
            },
            [2] = {
                name = "Cornerstone of Creation",
                bosses = {
                    { bossName = "Dausegne, the Fallen Oracle",  index = 2 },
                    { bossName = "Prototype Pantheon",           index = 4 },
                    { bossName = "Lihuvim, Principal Architect", index = 7 }
                }
            },
            [3] = {
                name = "Domination's Grasp",
                bosses = {
                    { bossName = "Anduin Wrynn",   index = 8 },
                    { bossName = "Lords of Dread", index = 9 },
                    { bossName = "Rygelon",        index = 10 }
                }
            },
            [4] = {
                name = "The Grand Design",
                bosses = {
                    { bossName = "The Jailer", index = 11 }
                }
            },
        }
    },
    -- template
    [0] = {
        name = "",
        wings = {
            [1] = {
                name = "",
                bosses = {
                    { bossName = "0", index = 1 },
                    { bossName = "0", index = 2 },
                    { bossName = "0", index = 3 }
                }
            },
        }
    },

}
local gossipData = {
    ["80675"] = { -- Cata
        [42612] = { raidID = 967, wingID = 1 },
        [42613] = { raidID = 967, wingID = 2 }
    },
    ["80633"] = { -- Pandaria
        [42620] = { raidID = 1008, wingID = 1 },
        [42621] = { raidID = 1008, wingID = 2 },
        [42622] = { raidID = 1009, wingID = 1 },
        [42623] = { raidID = 1009, wingID = 2 },
        [42624] = { raidID = 996, wingID = 1 },
        [42625] = { raidID = 1098, wingID = 1 },
        [42626] = { raidID = 1098, wingID = 2 },
        [42627] = { raidID = 1098, wingID = 3 },
        [42628] = { raidID = 1098, wingID = 4 },
        [42629] = { raidID = 1136, wingID = 1 },
        [42630] = { raidID = 1136, wingID = 2 },
        [42631] = { raidID = 1136, wingID = 3 },
        [42632] = { raidID = 1136, wingID = 4 }
    },
    ["94870"] = { -- Draenor
        [44390] = { raidID = 1228, wingID = 1 },
        [44391] = { raidID = 1228, wingID = 2 },
        [44392] = { raidID = 1228, wingID = 3 },
        [44393] = { raidID = 1205, wingID = 1 },
        [44394] = { raidID = 1205, wingID = 2 },
        [44395] = { raidID = 1205, wingID = 3 },
        [44396] = { raidID = 1205, wingID = 4 },
        [44397] = { raidID = 1448, wingID = 1 },
        [44398] = { raidID = 1448, wingID = 2 },
        [44399] = { raidID = 1448, wingID = 3 },
        [44400] = { raidID = 1448, wingID = 4 },
        [44401] = { raidID = 1448, wingID = 5 },
    },
    ["111246"] = { -- Legion
        [37110] = { raidID = 1520, wingID = 1 },
        [37111] = { raidID = 1520, wingID = 2 },
        [37112] = { raidID = 1520, wingID = 3 },
        [37113] = { raidID = 1530, wingID = 1 },
        [37114] = { raidID = 1530, wingID = 2 },
        [37115] = { raidID = 1530, wingID = 3 },
        [37116] = { raidID = 1530, wingID = 4 },
        [37117] = { raidID = 1648, wingID = 1 },
        [37118] = { raidID = 1676, wingID = 1 },
        [37119] = { raidID = 1676, wingID = 2 },
        [37120] = { raidID = 1676, wingID = 3 },
        [37121] = { raidID = 1676, wingID = 4 },
        [37122] = { raidID = 1712, wingID = 1 },
        [37123] = { raidID = 1712, wingID = 2 },
        [37124] = { raidID = 1712, wingID = 3 },
        [37125] = { raidID = 1712, wingID = 4 }
    },
    ["177193"] = { -- BFA Ally
        [52303] = { raidID = 1861, wingID = 1 },
        [52304] = { raidID = 1861, wingID = 2 },
        [52305] = { raidID = 1861, wingID = 3 },
        [52309] = { raidID = 2070, wingID = 1 },
        [52310] = { raidID = 2070, wingID = 2 },
        [52311] = { raidID = 2070, wingID = 3 },
        [52312] = { raidID = 2096, wingID = 1 },
        [52313] = { raidID = 2164, wingID = 1 },
        [52314] = { raidID = 2164, wingID = 2 },
        [52315] = { raidID = 2164, wingID = 3 },
        [52316] = { raidID = 2217, wingID = 1 },
        [52317] = { raidID = 2217, wingID = 2 },
        [52318] = { raidID = 2217, wingID = 3 },
        [52319] = { raidID = 2217, wingID = 4 }
    },
    ["177208"] = { -- BFA Horde
        [52303] = { raidID = 1861, wingID = 1 },
        [52304] = { raidID = 1861, wingID = 2 },
        [52305] = { raidID = 1861, wingID = 3 },
        [52306] = { raidID = 2070, wingID = 1 },
        [52307] = { raidID = 2070, wingID = 2 },
        [52308] = { raidID = 2070, wingID = 3 },
        [52312] = { raidID = 2096, wingID = 1 },
        [52313] = { raidID = 2164, wingID = 1 },
        [52314] = { raidID = 2164, wingID = 2 },
        [52315] = { raidID = 2164, wingID = 3 },
        [52316] = { raidID = 2217, wingID = 1 },
        [52317] = { raidID = 2217, wingID = 2 },
        [52318] = { raidID = 2217, wingID = 3 },
        [52319] = { raidID = 2217, wingID = 4 }
    },
    ["205959"] = { -- Shadowlands
        [110020] = { raidID = 2296, wingID = 1 },
        [110037] = { raidID = 2296, wingID = 2 },
        [110036] = { raidID = 2296, wingID = 3 },
        [110035] = { raidID = 2296, wingID = 4 },
        [110034] = { raidID = 2450, wingID = 1 },
        [110033] = { raidID = 2450, wingID = 2 },
        [110032] = { raidID = 2450, wingID = 3 },
        [110031] = { raidID = 2450, wingID = 4 },
        [110030] = { raidID = 2481, wingID = 1 },
        [110029] = { raidID = 2481, wingID = 2 },
        [110028] = { raidID = 2481, wingID = 3 },
        [110027] = { raidID = 2481, wingID = 4 }
    }
}

app.lfrData = lfrData;
local activeExt = false
local lockDownData = {}

GossipFrame:HookScript("OnShow", function()
    C_Timer.After(0.25, function()
        app:GossipLfr()
    end)
end)

GossipFrame:HookScript("OnHide", function()
    lockDownData = {}
    activeExt = false
end)



function app:GenerateLockDownData()
    for i = 1, GetNumSavedInstances() do
        local _, _, _, difficultyId, locked, _, _, isRaid, _, _, numEncounters, _, _, instanceId = GetSavedInstanceInfo(
            i)
        if (isRaid and (difficultyId == 7 or difficultyId == 17) and locked) then
            lockDownData[instanceId] = {}
            for j = 1, numEncounters do
                local _, _, killed = GetSavedInstanceEncounterInfo(i, j)
                lockDownData[instanceId][j] = killed
            end
        end
    end
end

function app:GossipLfr()
    lockDownData = {}
    app:GenerateLockDownData()

    local info = UnitGUID("target")
    if not info then return end

    local NPCtype, _, _, _, _, npc_id, _ = strsplit("-", info)
    local lfrNpc = gossipData[npc_id]
    if not lfrNpc then
        local children = { GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }
        for _, child in ipairs(children) do
            if child.CH then
                child.CH:Hide()
            end
        end
        return
    end
    app:UpdateLfrGossip(lfrNpc)
end

function app:UpdateLfrGossip(lfrNpc)
    local children = { GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }
    local yOffsetAdjustment = -19 -- Height adjustment for each child
    local firstY = nil
    local currentYOffset = 0

    for _, child in ipairs(children) do
        local data = child.GetData and child:GetData()
        if data and data.info and data.info.gossipOptionID then
            local gossipRef = lfrNpc[data.info.gossipOptionID]
            if gossipRef then
                local lfrG = lfrData[gossipRef.raidID]
                if lfrG then
                    local wing = lfrG.wings[gossipRef.wingID]
                    if wing then
                        activeExt = true
                        local lockDownInstance = lockDownData[gossipRef.raidID]

                        local totalBosses = #wing.bosses
                        local killed = 0
                        local bossTooltipLines = {}
                        for _, bossInfo in ipairs(wing.bosses) do
                            local killedState = lockDownInstance and lockDownInstance[bossInfo.index]
                            if killedState then
                                killed = killed + 1
                                table.insert(bossTooltipLines, app:textCFormat(COLORS.red, bossInfo.bossName))
                            else
                                table.insert(bossTooltipLines, bossInfo.bossName)
                            end
                        end

                        local prefix = "[" .. killed .. "/" .. totalBosses .. "]"
                        local displayText = prefix .. " " .. wing.name

                        local stateCol = false;
                        local collectedRefState = lfrCollected[gossipRef.raidID]
                        if collectedRefState then
                            stateCol = collectedRefState["wings"][gossipRef.wingID]
                        end

                        if killed > 0 and totalBosses > killed and stateCol == false then
                            displayText = app:textCFormat(COLORS.yellow, displayText)
                        end

                        if child.Icon and totalBosses == killed then
                            child.Icon:SetTexture(130751)
                            if stateCol == false then
                                displayText = app:textCFormat(COLORS.green, displayText)
                            end
                        end
                        if stateCol == true then
                            displayText = app:textCFormat(COLORS.red, displayText)
                        end
                        child:SetText(displayText)
                        child:SetHeight(16)

                        if child.CH == nil then
                            local mActionFrame = app:frameBuilder({
                                frameName = nil,
                                parent = child,
                                width = 50,
                                height = 16,
                                point = {
                                    pos = "BOTTOMRIGHT",
                                    x = 0,
                                    y = 0,
                                }
                            })
                            mActionFrame:SetBackdropColor(0, 0, 0, 0)
                            mActionFrame:SetBackdropBorderColor(0, 0, 0, 0)
                            local aBtn = app:buttonBuilder({
                                buttonName = nil,
                                parent = mActionFrame,
                                text = "TC/UW",
                                width = 45,
                                height = 16,
                                point = {
                                    pos = "BOTTOMLEFT",
                                    x = 0,
                                    y = 0,
                                }
                            })

                            aBtn:SetScript("OnEnter", function()
                                if activeExt then
                                    GameTooltip:SetOwner(GossipFrame, "ANCHOR_RIGHT", 0, -34)
                                    GameTooltip:SetText("Toggle Completed/Unmark Wing", 1, 1, 1)
                                    GameTooltip:AddLine(
                                        "This allows you to mark a raid wing as completed or unmark it, providing better visual tracking of your collection",
                                        nil, nil, nil, true)
                                    GameTooltip:AddLine(
                                        app:textCFormat(COLORS.red, "Red") ..
                                        " option text color will mark the completed state", nil, nil, nil, true)
                                    GameTooltip:Show()
                                end
                            end)
                            aBtn:SetScript("OnLeave", function()
                                if activeExt then
                                    GameTooltip:Hide()
                                end
                            end)
                            child.CH = mActionFrame;
                            child.Btn = aBtn;
                        else
                            child.CH:Show()
                        end

                        -- change btn refs for new gossip
                        child.Btn:SetScript("OnClick", function(self, button)
                            if button == "LeftButton" then
                                local collectedRef = lfrCollected[gossipRef.raidID]
                                if collectedRef then
                                    local state = collectedRef["wings"][gossipRef.wingID]
                                    collectedRef["wings"][gossipRef.wingID] = not state
                                    app:UpdateLfrGossip(lfrNpc)
                                end
                            end
                        end)

                        -- Adjust yOffset based on the first element with gossipOptionID
                        if not firstY then
                            firstY = select(5, child:GetPoint(1))
                        else
                            local currentX = select(4, child:GetPoint(1))
                            currentYOffset = currentYOffset + yOffsetAdjustment
                            child:SetPoint("TOPLEFT", currentX, firstY + currentYOffset)
                        end


                        child:SetScript("OnEnter", function()
                            if activeExt then
                                GameTooltip:SetOwner(GossipFrame, "ANCHOR_RIGHT", 0, -34)
                                GameTooltip:SetText("Wing State", 1, 1, 1)
                                for _, line in ipairs(bossTooltipLines) do
                                    GameTooltip:AddLine(line, nil, nil, nil, true)
                                end
                                GameTooltip:Show()
                            end
                        end)
                        child:SetScript("OnLeave", function()
                            if activeExt then
                                GameTooltip:Hide()
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- ========================
-- Section: debug ids
-- ========================
local function debugLockdown()
    for i = 1, GetNumSavedInstances() do
        local name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId =
            GetSavedInstanceInfo(i)
        if (isRaid and (difficultyId == 7 or difficultyId == 17)) then
            print(name)
            print(numEncounters)
            print(instanceId)
            print("---------------")
            for j = 1, numEncounters do
                local bossName, _, killed = GetSavedInstanceEncounterInfo(i, j)
                print(bossName)
                print(killed)
                print(j)
            end
        end
    end
end

local function debugGossip()
    local function getOptionID(self)
        print("clicked on " .. self:GetData().info.gossipOptionID)
    end

    local childs = { GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }
    for k, child in ipairs(childs) do
        local data = child.GetData and child:GetData()
        if data and data.info and data.info.gossipOptionID then
            if not child.hookedGossipExtraction then
                child:HookScript("OnClick", getOptionID)
                child.hookedGossipExtraction = true
            end
        end
    end
end
