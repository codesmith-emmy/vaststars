local entities = {
    {
        prototype_name = "指挥中心",
        dir = "N",
        x = 126,
        y = 120,
    },
    {
        prototype_name = "组装机残骸",
        dir = "N",
        items = {
            {"采矿机设计图",2},
            {"电线杆设计图",4},
            {"熔炼炉设计图",2},
            {"组装机设计图",2},
            {"空气过滤器设计图",4},
            {"水电站设计图",2},
            {"无人机仓库设计图",5},
        },
        x = 107,
        y = 129,
    },
    {
        prototype_name = "抽水泵残骸",
        dir = "S",
        items = {
            {"采矿机设计图",2},
            {"电线杆设计图",4},
            {"无人机仓库设计图",3},
            {"科研中心设计图",1},
            {"组装机设计图",2},
            {"道路建造站设计图",2},
            {"管道建造站设计图",2},
            {"送货车站设计图",2},
            {"收货车站设计图",2},
        },
        x = 113,
        y = 122,
    },
    {
        prototype_name = "无人机仓库",
        dir = "N",
        x = 117,
        y = 123,
    },
    {
        prototype_name = "建造中心",
        dir = "S",
        x = 120,
        y = 120,
    },
    {
        prototype_name = "风力发电机I",
        dir = "N",
        x = 121,
        y = 127,
    },
    {
        prototype_name = "排水口残骸",
        dir = "S",
        items = {
            {"破损运输车辆",4},
            {"太阳能板设计图",6},
            {"蓄电池设计图",15},
	        {"地下水挖掘机设计图",4},
	        {"电解厂设计图",1},
	        {"化工厂设计图",3},
            {"组装机设计图",2},
            {"无人机仓库设计图",3},
        },
        x = 133,
        y = 122,
    },
    {
        prototype_name = "组装机I",
        dir = "S",
        x = 133,
        y = 117,
    },
    {
        prototype_name = "熔炼炉I",
        dir = "N",
        x = 140,
        y = 126,
    },
    {
        prototype_name = "无人机仓库",
        dir = "N",
        x = 137,
        y = 126,
    },
    {
        prototype_name = "道路建造站",
        dir = "N",
        x = 137,
        y = 106,
    },
    {
        prototype_name = "无人机仓库",
        dir = "N",
        x = 137,
        y = 112,
    },
    {
        prototype_name = "采矿机I",
        dir = "N",
        x = 140,
        y = 112,
    },
    {
        prototype_name = "铁制电线杆",
        dir = "N",
        x = 136,
        y = 115,
    },
    {
        prototype_name = "铁制电线杆",
        dir = "N",
        x = 144,
        y = 115,
    },
    {
        prototype_name = "铁制电线杆",
        dir = "N",
        x = 136,
        y = 126,
    },
    {
        prototype_name = "铁制电线杆",
        dir = "N",
        x = 144,
        y = 126,
    },
}

local road = {
}

return {
    entities = entities,
    road = road,
}