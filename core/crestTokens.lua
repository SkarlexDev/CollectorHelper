local _, app = ...
local CLS = {
    DK = "DEATHKNIGHT",
    WA = "WARRIOR",
    PA = "PALADIN",
    HU = "HUNTER",
    SH = "SHAMAN",
    DH = "DEMONHUNTER",
    RO = "ROGUE",
    MO = "MONK",
    DR = "DRUID",
    PR = "PRIEST",
    MA = "MAGE",
    WL = "WARLOCK",
    EV = "EVOKER",
    ANY = "ANY"
}
app.CLS = CLS

local COMBINATIONS = {
    MPLATE = { CLS.PA, CLS.WA, CLS.DK },
    SHIELD = { CLS.PA, CLS.SH, CLS.WA },
    WAND = { CLS.MA, CLS.PR, CLS.WL },
}

local TOKEN_ARMOR = {
    -- DF
    [208926] = {
        [209376] = { CLS.DR, CLS.HU, CLS.MO },
        [209369] = COMBINATIONS.MPLATE,
        [209360] = { CLS.MA, CLS.DR, CLS.PR, CLS.SH, CLS.WL, CLS.MO, CLS.EV },
        [209361] = COMBINATIONS.MPLATE,
        [209379] = COMBINATIONS.SHIELD,
        [209377] = COMBINATIONS.WAND,
        [209375] = { CLS.HU },
        [209366] = COMBINATIONS.MPLATE,
        [209359] = { CLS.DH },
        [209370] = { CLS.RO, CLS.MO, CLS.DH },
        [209371] = COMBINATIONS.MPLATE,
        [209372] = { CLS.MA, CLS.DR, CLS.PR, CLS.SH, CLS.WL, CLS.EV },
        [209362] = { CLS.RO, CLS.SH, CLS.MO },
        [209373] = { CLS.RO },
        [209363] = COMBINATIONS.MPLATE,
        [209374] = { CLS.MA, CLS.PA, CLS.WL, CLS.MO, CLS.EV },
        [209364] = { CLS.PA, CLS.DR, CLS.PR, CLS.SH, CLS.MO, CLS.EV },
        [209365] = { CLS.RO, CLS.SH, CLS.MO, CLS.DH },
        [209378] = { CLS.MA, CLS.PA, CLS.DR, CLS.PR, CLS.SH, CLS.WL, CLS.MO, CLS.EV }
    },
}
