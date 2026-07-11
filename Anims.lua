local table_insert = table.insert

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({_tasks = {}, _destroyed = false}, Maid)
end

function Maid:GiveTask(task)
    if self._destroyed then
        self:_cleanupTask(task)
        return
    end
    table_insert(self._tasks, task)
    return task
end

function Maid:GiveTasks(...)
    for _, task in ipairs({...}) do
        self:GiveTask(task)
    end
end

function Maid:_cleanupTask(task)
    local taskType = typeof(task)
    if taskType == "RBXScriptConnection" then
        task:Disconnect()
    elseif taskType == "Instance" then
        task:Destroy()
    elseif taskType == "function" then
        task()
    elseif taskType == "table" and type(task.Destroy) == "function" then
        task:Destroy()
    end
end

function Maid:DoCleaning()
    if self._destroyed then return end
    self._destroyed = true
    for _, task in ipairs(self._tasks) do
        self:_cleanupTask(task)
    end
    self._tasks = {}
end

function Maid:Destroy()
    self:DoCleaning()
end

local RootMaid = Maid.new()
local shared = odh_shared_plugins

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function isR15()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        return humanoid.RigType == Enum.HumanoidRigType.R15
    end
    return false
end

if isR15() then
    do
        local feAnimSection = shared.AddSection("FE Animations")
        local FEAnimMaid = Maid.new()
        RootMaid:GiveTask(FEAnimMaid)

        local feAnimEnabled = false
        local animState = {all="Default", idle="Default", walk="Default", run="Default", jump="Default", climb="Default", fall="Default"}
        local originalAnims = {}

        local animPresets = {
            ["Default"] = nil,
            ["OG Rthro Run"] = {run = "http://www.roblox.com/asset/?id=9801814462"},
            ["Vampire"] = {
                idle1 = "http://www.roblox.com/asset/?id=1083445855",
                idle2 = "http://www.roblox.com/asset/?id=1083450166",
                walk  = "http://www.roblox.com/asset/?id=1083473930",
                run   = "http://www.roblox.com/asset/?id=1083462077",
                jump  = "http://www.roblox.com/asset/?id=1083455352",
                climb = "http://www.roblox.com/asset/?id=1083439238",
                fall  = "http://www.roblox.com/asset/?id=1083443587"
            },
            ["Hero"] = {
                idle1 = "http://www.roblox.com/asset/?id=616111295",
                idle2 = "http://www.roblox.com/asset/?id=616113536",
                walk  = "http://www.roblox.com/asset/?id=616122287",
                run   = "http://www.roblox.com/asset/?id=616117076",
                jump  = "http://www.roblox.com/asset/?id=616115533",
                climb = "http://www.roblox.com/asset/?id=616104706",
                fall  = "http://www.roblox.com/asset/?id=616108001"
            },
            ["Zombie Classic"] = {
                idle1 = "http://www.roblox.com/asset/?id=616158929",
                idle2 = "http://www.roblox.com/asset/?id=616160636",
                walk  = "http://www.roblox.com/asset/?id=616168032",
                run   = "http://www.roblox.com/asset/?id=616163682",
                jump  = "http://www.roblox.com/asset/?id=616161997",
                climb = "http://www.roblox.com/asset/?id=616156119",
                fall  = "http://www.roblox.com/asset/?id=616157476"
            },
            ["Mage"] = {
                idle1 = "http://www.roblox.com/asset/?id=707742142",
                idle2 = "http://www.roblox.com/asset/?id=707855907",
                walk  = "http://www.roblox.com/asset/?id=707897309",
                run   = "http://www.roblox.com/asset/?id=707861613",
                jump  = "http://www.roblox.com/asset/?id=707853694",
                climb = "http://www.roblox.com/asset/?id=707826056",
                fall  = "http://www.roblox.com/asset/?id=707829716"
            },
            ["Ghost"] = {
                idle1 = "http://www.roblox.com/asset/?id=616006778",
                idle2 = "http://www.roblox.com/asset/?id=616008087",
                walk  = "http://www.roblox.com/asset/?id=616010382",
                run   = "http://www.roblox.com/asset/?id=616013216",
                jump  = "http://www.roblox.com/asset/?id=616008936",
                climb = "http://www.roblox.com/asset/?id=616003713",
                fall  = "http://www.roblox.com/asset/?id=616005863"
            },
            ["Elder"] = {
                idle1 = "http://www.roblox.com/asset/?id=845397899",
                idle2 = "http://www.roblox.com/asset/?id=845400520",
                walk  = "http://www.roblox.com/asset/?id=845403856",
                run   = "http://www.roblox.com/asset/?id=845386501",
                jump  = "http://www.roblox.com/asset/?id=845398858",
                climb = "http://www.roblox.com/asset/?id=845392038",
                fall  = "http://www.roblox.com/asset/?id=845396048"
            },
            ["Levitation"] = {
                idle1 = "http://www.roblox.com/asset/?id=616006778",
                idle2 = "http://www.roblox.com/asset/?id=616008087",
                walk  = "http://www.roblox.com/asset/?id=616013216",
                run   = "http://www.roblox.com/asset/?id=616010382",
                jump  = "http://www.roblox.com/asset/?id=616008936",
                climb = "http://www.roblox.com/asset/?id=616003713",
                fall  = "http://www.roblox.com/asset/?id=616005863"
            },
            ["Astronaut"] = {
                idle1 = "http://www.roblox.com/asset/?id=891621366",
                idle2 = "http://www.roblox.com/asset/?id=891633237",
                walk  = "http://www.roblox.com/asset/?id=891667138",
                run   = "http://www.roblox.com/asset/?id=891636393",
                jump  = "http://www.roblox.com/asset/?id=891627522",
                climb = "http://www.roblox.com/asset/?id=891609353",
                fall  = "http://www.roblox.com/asset/?id=891617961"
            },
            ["Ninja"] = {
                idle1 = "http://www.roblox.com/asset/?id=656117400",
                idle2 = "http://www.roblox.com/asset/?id=656118341",
                walk  = "http://www.roblox.com/asset/?id=656121766",
                run   = "http://www.roblox.com/asset/?id=656118852",
                jump  = "http://www.roblox.com/asset/?id=656117878",
                climb = "http://www.roblox.com/asset/?id=656114359",
                fall  = "http://www.roblox.com/asset/?id=656115606"
            },
            ["Werewolf"] = {
                idle1 = "http://www.roblox.com/asset/?id=1083195517",
                idle2 = "http://www.roblox.com/asset/?id=1083214717",
                walk  = "http://www.roblox.com/asset/?id=1083178339",
                run   = "http://www.roblox.com/asset/?id=1083216690",
                jump  = "http://www.roblox.com/asset/?id=1083218792",
                climb = "http://www.roblox.com/asset/?id=1083182000",
                fall  = "http://www.roblox.com/asset/?id=1083189019"
            },
            ["Cartoon"] = {
                idle1 = "http://www.roblox.com/asset/?id=742637544",
                idle2 = "http://www.roblox.com/asset/?id=742638445",
                walk  = "http://www.roblox.com/asset/?id=742640026",
                run   = "http://www.roblox.com/asset/?id=742638842",
                jump  = "http://www.roblox.com/asset/?id=742637942",
                climb = "http://www.roblox.com/asset/?id=742636889",
                fall  = "http://www.roblox.com/asset/?id=742637151"
            },
            ["Pirate"] = {
                idle1 = "http://www.roblox.com/asset/?id=750781874",
                idle2 = "http://www.roblox.com/asset/?id=750782770",
                walk  = "http://www.roblox.com/asset/?id=750785693",
                run   = "http://www.roblox.com/asset/?id=750783738",
                jump  = "http://www.roblox.com/asset/?id=750782230",
                climb = "http://www.roblox.com/asset/?id=750779899",
                fall  = "http://www.roblox.com/asset/?id=750780242"
            },
            ["Sneaky"] = {
                idle1 = "http://www.roblox.com/asset/?id=1132473842",
                idle2 = "http://www.roblox.com/asset/?id=1132477671",
                walk  = "http://www.roblox.com/asset/?id=1132510133",
                run   = "http://www.roblox.com/asset/?id=1132494274",
                jump  = "http://www.roblox.com/asset/?id=1132489853",
                climb = "http://www.roblox.com/asset/?id=1132461372",
                fall  = "http://www.roblox.com/asset/?id=1132469004"
            },
            ["Toy"] = {
                idle1 = "http://www.roblox.com/asset/?id=782841498",
                idle2 = "http://www.roblox.com/asset/?id=782845736",
                walk  = "http://www.roblox.com/asset/?id=782843345",
                run   = "http://www.roblox.com/asset/?id=782842708",
                jump  = "http://www.roblox.com/asset/?id=782847020",
                climb = "http://www.roblox.com/asset/?id=782843869",
                fall  = "http://www.roblox.com/asset/?id=782846423"
            },
            ["Knight"] = {
                idle1 = "http://www.roblox.com/asset/?id=657595757",
                idle2 = "http://www.roblox.com/asset/?id=657568135",
                walk  = "http://www.roblox.com/asset/?id=657552124",
                run   = "http://www.roblox.com/asset/?id=657564596",
                jump  = "http://www.roblox.com/asset/?id=658409194",
                climb = "http://www.roblox.com/asset/?id=658360781",
                fall  = "http://www.roblox.com/asset/?id=657600338"
            },
            ["Confident"] = {
                idle1 = "http://www.roblox.com/asset/?id=1069977950",
                idle2 = "http://www.roblox.com/asset/?id=1069987858",
                walk  = "http://www.roblox.com/asset/?id=1070017263",
                run   = "http://www.roblox.com/asset/?id=1070001516",
                jump  = "http://www.roblox.com/asset/?id=1069984524",
                climb = "http://www.roblox.com/asset/?id=1069946257",
                fall  = "http://www.roblox.com/asset/?id=1069973677"
            },
            ["Popstar"] = {
                idle1 = "http://www.roblox.com/asset/?id=1212900985",
                idle2 = "http://www.roblox.com/asset/?id=1212900985",
                walk  = "http://www.roblox.com/asset/?id=1212980338",
                run   = "http://www.roblox.com/asset/?id=1212980348",
                jump  = "http://www.roblox.com/asset/?id=1212954642",
                climb = "http://www.roblox.com/asset/?id=1213044953",
                fall  = "http://www.roblox.com/asset/?id=1212900995"
            },
            ["Princess"] = {
                idle1 = "http://www.roblox.com/asset/?id=941003647",
                idle2 = "http://www.roblox.com/asset/?id=941013098",
                walk  = "http://www.roblox.com/asset/?id=941028902",
                run   = "http://www.roblox.com/asset/?id=941015281",
                jump  = "http://www.roblox.com/asset/?id=941008832",
                climb = "http://www.roblox.com/asset/?id=940996062",
                fall  = "http://www.roblox.com/asset/?id=941000007"
            },
            ["Cowboy"] = {
                idle1 = "http://www.roblox.com/asset/?id=1014390418",
                idle2 = "http://www.roblox.com/asset/?id=1014398616",
                walk  = "http://www.roblox.com/asset/?id=1014421541",
                run   = "http://www.roblox.com/asset/?id=1014401683",
                jump  = "http://www.roblox.com/asset/?id=1014394726",
                climb = "http://www.roblox.com/asset/?id=1014380606",
                fall  = "http://www.roblox.com/asset/?id=1014384571"
            },
            ["Patrol"] = {
                idle1 = "http://www.roblox.com/asset/?id=1149612882",
                idle2 = "http://www.roblox.com/asset/?id=1150842221",
                walk  = "http://www.roblox.com/asset/?id=1151231493",
                run   = "http://www.roblox.com/asset/?id=1150967949",
                jump  = "http://www.roblox.com/asset/?id=1150944216",
                climb = "http://www.roblox.com/asset/?id=1148811837",
                fall  = "http://www.roblox.com/asset/?id=1148863382"
            },
            ["Zombie FE"] = {
                idle1 = "http://www.roblox.com/asset/?id=3489171152",
                idle2 = "http://www.roblox.com/asset/?id=3489171152",
                walk  = "http://www.roblox.com/asset/?id=3489174223",
                run   = "http://www.roblox.com/asset/?id=3489173414",
                jump  = "http://www.roblox.com/asset/?id=616161997",
                climb = "http://www.roblox.com/asset/?id=616156119",
                fall  = "http://www.roblox.com/asset/?id=616157476"
            },
            ["Catwalk Glam"] = {
                idle1 = "http://www.roblox.com/asset/?id=133806214992291",
                idle2 = "http://www.roblox.com/asset/?id=133806214992291",
                walk  = "http://www.roblox.com/asset/?id=109168724482748",
                run   = "http://www.roblox.com/asset/?id=81024476153754",
                jump  = "http://www.roblox.com/asset/?id=116936326516985",
                climb = "http://www.roblox.com/asset/?id=119377220967554",
                fall  = "http://www.roblox.com/asset/?id=92294537340807"
            },
            ["Amazon Unboxed"] = {
                idle1 = "http://www.roblox.com/asset/?id=98281136301627",
                idle2 = "http://www.roblox.com/asset/?id=98281136301627",
                walk  = "http://www.roblox.com/asset/?id=90478085024465",
                run   = "http://www.roblox.com/asset/?id=134824450619865",
                jump  = "http://www.roblox.com/asset/?id=121454505477205",
                climb = "http://www.roblox.com/asset/?id=121145883950231",
                fall  = "http://www.roblox.com/asset/?id=94788218468396"
            },
            ["Glow Motion"] = {
                idle1 = "https://www.roblox.com/asset/?id=137764781910579",
                idle2 = "https://www.roblox.com/asset/?id=137764781910579",
                walk  = "http://www.roblox.com/asset/?id=85809016093530",
                run   = "http://www.roblox.com/asset/?id=101925097435036",
                jump  = "http://www.roblox.com/asset/?id=74159004634379",
                climb = "http://www.roblox.com/asset/?id=108236155509584",
                fall  = "https://www.roblox.com/asset/?id=98070939608691"
            },
            ["Bubbly"] = {
                idle1 = "https://www.roblox.com/asset/?id=10921054344",
                idle2 = "https://www.roblox.com/asset/?id=10921054344",
                walk  = "http://www.roblox.com/asset/?id=10980888364",
                run   = "http://www.roblox.com/asset/?id=10921057244",
                jump  = "http://www.roblox.com/asset/?id=10921062673",
                climb = "http://www.roblox.com/asset/?id=10921053544",
                fall  = "https://www.roblox.com/asset/?id=10921061530"
            },
            ["Adidas Comm"] = {
                idle1 = "https://www.roblox.com/asset/?id=122257458498464",
                idle2 = "https://www.roblox.com/asset/?id=122257458498464",
                walk  = "http://www.roblox.com/asset/?id=122150855457006",
                run   = "http://www.roblox.com/asset/?id=82598234841035",
                jump  = "http://www.roblox.com/asset/?id=75290611992385",
                climb = "http://www.roblox.com/asset/?id=88763136693023",
                fall  = "https://www.roblox.com/asset/?id=98600215928904"
            },
            ["KATSEYE"] = {
                idle1 = "https://www.roblox.com/asset/?id=108187809145790",
                idle2 = "https://www.roblox.com/asset/?id=108187809145790",
                walk  = "http://www.roblox.com/asset/?id=99182913548783",
                run   = "http://www.roblox.com/asset/?id=73117360545482",
                jump  = "http://www.roblox.com/asset/?id=103632305262747",
                climb = "http://www.roblox.com/asset/?id=106213237973858",
                fall  = "https://www.roblox.com/asset/?id=127802717128367"
            },
            ["Wicked Popular"] = {
                idle1 = "https://www.roblox.com/asset/?id=118832222982049",
                idle2 = "https://www.roblox.com/asset/?id=118832222982049",
                walk  = "http://www.roblox.com/asset/?id=92072849924640",
                run   = "http://www.roblox.com/asset/?id=72301599441680",
                jump  = "http://www.roblox.com/asset/?id=104325245285198",
                climb = "http://www.roblox.com/asset/?id=131326830509784",
                fall  = "https://www.roblox.com/asset/?id=121152442762481"
            },
            ["Dizzy"] = {
                idle1 = "http://www.roblox.com/asset/?id=132806359718468",
                idle2 = "http://www.roblox.com/asset/?id=132806359718468",
                walk  = "http://www.roblox.com/asset/?id=110106034100313",
                run   = "http://www.roblox.com/asset/?id=138305342272849",
                jump  = "http://www.roblox.com/asset/?id=108564434408211",
                climb = "http://www.roblox.com/asset/?id=93550710314258",
                fall  = "http://www.roblox.com/asset/?id=138967706335414"
            },
            ["WDTL"] = {
                idle1 = "http://www.roblox.com/asset/?id=92849173543269",
                idle2 = "http://www.roblox.com/asset/?id=92849173543269",
                walk  = "http://www.roblox.com/asset/?id=73718308412641",
                run   = "http://www.roblox.com/asset/?id=135515454877967",
                jump  = "http://www.roblox.com/asset/?id=78508480717326",
                climb = "http://www.roblox.com/asset/?id=129447497744818",
                fall  = "http://www.roblox.com/asset/?id=78147885297412"
            },
            ["Billie Eilish"] = {
                idle1 = "http://www.roblox.com/asset/?id=102934602884410",
                idle2 = "http://www.roblox.com/asset/?id=102934602884410",
                walk  = "http://www.roblox.com/asset/?id=81877886552514",
                run   = "http://www.roblox.com/asset/?id=100920560634123",
                jump  = "http://www.roblox.com/asset/?id=117602630922781",
                climb = "http://www.roblox.com/asset/?id=117873469361430",
                fall  = "http://www.roblox.com/asset/?id=81072141180299"
            },
            ["Cute Bouncy"] = {
                idle1 = "http://www.roblox.com/asset/?id=88464649697812",
                idle2 = "http://www.roblox.com/asset/?id=88464649697812",
                walk  = "http://www.roblox.com/asset/?id=98713727778027",
                run   = "http://www.roblox.com/asset/?id=133955346539948",
                jump  = "http://www.roblox.com/asset/?id=124147147418885",
                climb = "http://www.roblox.com/asset/?id=95542189442725",
                fall  = "http://www.roblox.com/asset/?id=128620818122982"
            },
            ["Cute"] = {
                idle1 = "http://www.roblox.com/asset/?id=85735421117197",
                idle2 = "http://www.roblox.com/asset/?id=85735421117197",
                walk  = "http://www.roblox.com/asset/?id=140409718187215",
                run   = "http://www.roblox.com/asset/?id=118375157537412",
                jump  = "http://www.roblox.com/asset/?id=132381016103721",
                climb = "http://www.roblox.com/asset/?id=86318575131600",
                fall  = "http://www.roblox.com/asset/?id=77496925287217"
            },
            ["Jolly"] = {
                idle1 = "http://www.roblox.com/asset/?id=136145727878709",
                idle2 = "http://www.roblox.com/asset/?id=136145727878709",
                walk  = "http://www.roblox.com/asset/?id=83277136078444",
                run   = "http://www.roblox.com/asset/?id=124419804298310",
                jump  = "http://www.roblox.com/asset/?id=122115816220842",
                climb = "http://www.roblox.com/asset/?id=107190574095036",
                fall  = "http://www.roblox.com/asset/?id=85263802503331"
            },
            ["Cute Kawaii"] = {
                idle1 = "http://www.roblox.com/asset/?id=72311682331639",
                idle2 = "http://www.roblox.com/asset/?id=72311682331639",
                walk  = "http://www.roblox.com/asset/?id=107212872423561",
                run   = "http://www.roblox.com/asset/?id=118582510545072",
                jump  = "http://www.roblox.com/asset/?id=112952548321695",
                climb = "http://www.roblox.com/asset/?id=126383408493776",
                fall  = "http://www.roblox.com/asset/?id=83307333809322"
            },
            ["Doll 3.0"] = {
                idle1 = "http://www.roblox.com/asset/?id=83032187271383",
                idle2 = "http://www.roblox.com/asset/?id=83032187271383",
                walk  = "http://www.roblox.com/asset/?id=78434960966537",
                run   = "http://www.roblox.com/asset/?id=129768396663808",
                jump  = "http://www.roblox.com/asset/?id=75369057994828",
                climb = "http://www.roblox.com/asset/?id=112371892133970",
                fall  = "http://www.roblox.com/asset/?id=81027444073311"
            },
            ["Victoria Model"] = {
                idle1 = "http://www.roblox.com/asset/?id=132069965396465",
                idle2 = "http://www.roblox.com/asset/?id=132069965396465",
                walk  = "http://www.roblox.com/asset/?id=84814915379579",
                run   = "http://www.roblox.com/asset/?id=84814915379579",
                jump  = "http://www.roblox.com/asset/?id=78163261581163",
                climb = "http://www.roblox.com/asset/?id=87772134905508",
                fall  = "http://www.roblox.com/asset/?id=110073924253388"
            },
            ["Bike/Bicyclist"] = {
                idle1 = "http://www.roblox.com/asset/?id=126390120399173",
                idle2 = "http://www.roblox.com/asset/?id=136791517336633",
                walk  = "http://www.roblox.com/asset/?id=98707881660541",
                run   = "http://www.roblox.com/asset/?id=102775737211919",
                jump  = "http://www.roblox.com/asset/?id=129144847881258",
                climb = "http://www.roblox.com/asset/?id=88267082364595",
                fall  = "http://www.roblox.com/asset/?id=110684787086498"
            },
            ["Animal"] = {
                idle1 = "http://www.roblox.com/asset/?id=128838183008466",
                idle2 = "http://www.roblox.com/asset/?id=99689776099970",
                walk  = "http://www.roblox.com/asset/?id=112238064449133",
                run   = "http://www.roblox.com/asset/?id=97412731442167",
                jump  = "http://www.roblox.com/asset/?id=123565665274439",
                climb = "http://www.roblox.com/asset/?id=75085836535654",
                fall  = "http://www.roblox.com/asset/?id=124705831982259"
            },
            ["It-Girl Essential Model"] = {
                idle1 = "http://www.roblox.com/asset/?id=132232079260125",
                idle2 = "http://www.roblox.com/asset/?id=102440789796215",
                walk  = "http://www.roblox.com/asset/?id=86579666661215",
                run   = "http://www.roblox.com/asset/?id=83336349930143",
                jump  = "http://www.roblox.com/asset/?id=103382156539106",
                climb = "http://www.roblox.com/asset/?id=77385815954046",
                fall  = "http://www.roblox.com/asset/?id=127262648208409"
            },
            ["Oldschool"] = {
                idle1 = "http://www.roblox.com/asset/?id=10921230744",
                idle2 = "http://www.roblox.com/asset/?id=10921232093",
                walk  = "http://www.roblox.com/asset/?id=10921244891",
                run   = "http://www.roblox.com/asset/?id=10921240218",
                jump  = "http://www.roblox.com/asset/?id=10921242013",
                climb = "http://www.roblox.com/asset/?id=10921229866",
                fall  = "http://www.roblox.com/asset/?id=10921241244"
            },
            ["Spider"] = {
                idle1 = "http://www.roblox.com/asset/?id=112316814377814",
                idle2 = "http://www.roblox.com/asset/?id=103439018552145",
                walk  = "http://www.roblox.com/asset/?id=109976439277879",
                run   = "http://www.roblox.com/asset/?id=119985832593347",
                jump  = "http://www.roblox.com/asset/?id=87979233462906",
                climb = "http://www.roblox.com/asset/?id=119278342251995",
                fall  = "http://www.roblox.com/asset/?id=71112238570777"
            },
            ["Joy"] = {
                idle1 = "http://www.roblox.com/asset/?id=119957475250242",
                idle2 = "http://www.roblox.com/asset/?id=101200477339169",
                walk  = "http://www.roblox.com/asset/?id=112597572150963",
                run   = "http://www.roblox.com/asset/?id=96521659811743",
                jump  = "http://www.roblox.com/asset/?id=82500357520736",
                climb = "http://www.roblox.com/asset/?id=110061716873830",
                fall  = "http://www.roblox.com/asset/?id=132095139090357"
            },
        }

        local animMap = {
            idle  = { folder = "idle",  slots = { { child = "Animation1", origKey = "idle1" }, { child = "Animation2", origKey = "idle2" } } },
            walk  = { folder = "walk",  slots = { { child = "WalkAnim",   origKey = "walk"  } } },
            run   = { folder = "run",   slots = { { child = "RunAnim",    origKey = "run"   } } },
            jump  = { folder = "jump",  slots = { { child = "JumpAnim",   origKey = "jump"  } } },
            climb = { folder = "climb", slots = { { child = "ClimbAnim",  origKey = "climb" } } },
            fall  = { folder = "fall",  slots = { { child = "FallAnim",   origKey = "fall"  } } },
        }

        local allAnimOptions = {
            "Default", "Vampire", "Hero", "Zombie Classic", "Mage", "Ghost",
            "Elder", "Levitation", "Astronaut", "Ninja", "Werewolf", "Cartoon",
            "Pirate", "Sneaky", "Toy", "Knight", "Confident", "Popstar",
            "Princess", "Cowboy", "Patrol", "Zombie FE", "Catwalk Glam", "Amazon Unboxed",
            "Glow Motion", "Bubbly", "Adidas Comm", "KATSEYE", "Wicked Popular",
            "Dizzy", "WDTL", "Billie Eilish", "Cute Bouncy", "Cute",
            "Jolly", "Cute Kawaii", "Doll 3.0", "Victoria Model",
            "Bike/Bicyclist", "Animal", "It-Girl Essential Model",
            "Oldschool", "Spider", "Joy"
        }

        local runAnimOptions = {
            "Default", "OG Rthro Run", "Vampire", "Hero", "Zombie Classic", "Mage", "Ghost",
            "Elder", "Levitation", "Astronaut", "Ninja", "Werewolf", "Cartoon",
            "Pirate", "Sneaky", "Toy", "Knight", "Confident", "Popstar",
            "Princess", "Cowboy", "Patrol", "Zombie FE", "Catwalk Glam", "Amazon Unboxed",
            "Glow Motion", "Bubbly", "Adidas Comm", "KATSEYE", "Wicked Popular",
            "Dizzy", "WDTL", "Billie Eilish", "Cute Bouncy", "Cute",
            "Jolly", "Cute Kawaii", "Doll 3.0", "Victoria Model",
            "Bike/Bicyclist", "Animal", "It-Girl Essential Model",
            "Oldschool", "Spider", "Joy"
        }

        local function saveOriginalAnimations(character)
            local Animate = character:FindFirstChild("Animate")
            if not Animate then return false end

            for _, info in pairs(animMap) do
                local folder = Animate:FindFirstChild(info.folder)
                if folder then
                    for _, slot in ipairs(info.slots) do
                        local anim = folder:FindFirstChild(slot.child)
                        if anim and anim.AnimationId and anim.AnimationId ~= "" then
                            originalAnims[slot.origKey] = anim.AnimationId
                        end
                    end
                end
            end
            return true
        end

        local function stopAllAnimations()
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end

        local function restoreDefaultAnimations()
            if not LocalPlayer or not LocalPlayer.Character then return end
            local character = LocalPlayer.Character
            local Animate = character:FindFirstChild("Animate")
            if not Animate then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

            stopAllAnimations()
            Animate.Disabled = true
            task.wait(0.1)

            for animType, info in pairs(animMap) do
                local folder = Animate:FindFirstChild(info.folder)
                if folder then
                    for _, slot in ipairs(info.slots) do
                        local anim = folder:FindFirstChild(slot.child)
                        if anim and originalAnims[slot.origKey] then
                            anim.AnimationId = originalAnims[slot.origKey]

                            if (animType == "jump" or animType == "fall") and animator then
                                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                    if track.Animation and track.Animation.AnimationId == anim.AnimationId then
                                        track:Stop(0)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            Animate.Disabled = false
        end

        local function getPresetForType(animType)
            if animState[animType] ~= "Default" then return animState[animType] end
            if animState.all ~= "Default" then return animState.all end
            return "Default"
        end

        local function applyAnimations()
            if not feAnimEnabled then return end
            if not LocalPlayer or not LocalPlayer.Character then return end

            local character = LocalPlayer.Character
            local Animate = character:FindFirstChild("Animate")
            if not Animate then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

            stopAllAnimations()
            Animate.Disabled = true
            task.wait(0.1)

            for animType, info in pairs(animMap) do
                local presetName = getPresetForType(animType)
                local preset = animPresets[presetName]
                local folder = Animate:FindFirstChild(info.folder)

                if folder then
                    for _, slot in ipairs(info.slots) do
                        local anim = folder:FindFirstChild(slot.child)
                        if anim then
                            local newId
                            if presetName == "Default" then
                                newId = originalAnims[slot.origKey]
                            elseif preset and preset[slot.origKey] then
                                newId = preset[slot.origKey]
                            end

                            if newId then
                                anim.AnimationId = newId

                                if (animType == "jump" or animType == "fall") and animator then
                                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                        if track.Animation and track.Animation.AnimationId == anim.AnimationId then
                                            track:Stop(0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            Animate.Disabled = false
        end

        local feAnimCharConn = nil
        local feAnimDiedConn = nil

        local function applyOnSpawn(character)
            local humanoid = character:WaitForChild("Humanoid", 10)
            if not humanoid then return end

            local Animate = character:WaitForChild("Animate", 10)
            if not Animate then return end

            local idle = Animate:WaitForChild("idle", 5)
            if not idle then return end
            idle:WaitForChild("Animation1", 5)

            saveOriginalAnimations(character)
            applyAnimations()

            task.wait(0.5)
            if feAnimEnabled then
                applyAnimations()
            end

            if feAnimDiedConn then
                feAnimDiedConn:Disconnect()
                feAnimDiedConn = nil
            end

            feAnimDiedConn = humanoid.Died:Connect(function()
                if feAnimDiedConn then
                    feAnimDiedConn:Disconnect()
                    feAnimDiedConn = nil
                end
            end)

            FEAnimMaid:GiveTask(feAnimDiedConn)
        end

        local function enableFEAnims()
            if feAnimCharConn then
                feAnimCharConn:Disconnect()
                feAnimCharConn = nil
            end
            if feAnimDiedConn then
                feAnimDiedConn:Disconnect()
                feAnimDiedConn = nil
            end

            if LocalPlayer.Character then
                task.spawn(applyOnSpawn, LocalPlayer.Character)
            end

            feAnimCharConn = LocalPlayer.CharacterAdded:Connect(function(character)
                task.spawn(applyOnSpawn, character)
            end)

            FEAnimMaid:GiveTask(feAnimCharConn)
        end

        local function disableFEAnims()
            if feAnimCharConn then
                feAnimCharConn:Disconnect()
                feAnimCharConn = nil
            end
            FEAnimMaid:DoCleaning()

            animState.all   = "Default"
            animState.idle  = "Default"
            animState.walk  = "Default"
            animState.run   = "Default"
            animState.jump  = "Default"
            animState.climb = "Default"
            animState.fall  = "Default"

            restoreDefaultAnimations()
        end

        feAnimSection:AddToggle("Enable FE Anims", function(enabled)
            feAnimEnabled = enabled
            if enabled then
                enableFEAnims()
            else
                disableFEAnims()
            end
        end)

        feAnimSection:AddDropdown("All Animations", allAnimOptions, function(selected)
            if not feAnimEnabled then return end
            animState.all = selected
            applyAnimations()
        end)

        local dropdowns = {
            { label = "Idle Animation",  key = "idle"  },
            { label = "Walk Animation",  key = "walk"  },
            { label = "Run Animation",   key = "run"   },
            { label = "Jump Animation",  key = "jump"  },
            { label = "Climb Animation", key = "climb" },
            { label = "Fall Animation",  key = "fall"  },
        }

        for _, dd in ipairs(dropdowns) do
            local options = allAnimOptions
            if dd.key == "run" then
                options = runAnimOptions
            end
            feAnimSection:AddDropdown(dd.label, options, function(selected)
                if not feAnimEnabled then return end
                animState[dd.key] = selected
                applyAnimations()
            end)
        end

        RootMaid:GiveTask(function()
            feAnimEnabled = false
            disableFEAnims()
        end)
    end
end
