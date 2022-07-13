local guide = {
	{
        name = "guide-1",
		narrative = {
            {"哔哩..哔哗..已迫降在代号P4031的星球。尚未发现任何生命迹象..(失望)", "textures/guide/guide-6.texture"},
            {"哔哩..哔哗..哔哩..启动大气分析协议中..P4031缺少氧气..(失望)"},
            {"哔哩..哔哗..哔哩..启动地质分析协议中..P4031铁铝丰富..(轻松)","textures/guide/guide-1.texture"},
            {"哔哩..哔哗..启动生存可靠性分析..0.04565%存活概率..(情绪表达跳过中)","textures/guide/guide-4.texture"},
            {"博士，作为助理AI，我建议你立刻开始工作..哔哩..你的剩余生存时间理论上只有348.26地球小时..(担忧)", "textures/guide/guide-6.texture"},
            {"迫降不算太糟糕，我们先清理指挥中心周边残骸，兴许能找到一些有用的物资..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"序章","迫降P4031"},
            task = {
                "清除废墟",
            },
            guide_progress = 5,
        },
        prerequisites = {},
	},

    {
        name = "guide-2",
		narrative = {
            {"我们捡到了不少有价值的破烂..哔哩..物资。科技就是第一生产力，建议先建造一所科研中心..(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 10,
            task = {
                "放置科研中心",
            }
        },
        prerequisites = {
            "清除废墟",
        },
	},

    {
        name = "guide-3",
		narrative = {
            {"哔哩..我们终于恢复了研究能力..哔哩..目前存活概率提升为0.07672%..(轻松)", "textures/guide/guide-1.texture"},
            {"哔哩..让我们点击“研究中心”按钮，开始研究第一个科技..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 15,
            task = {
            }
        },
        prerequisites = {
            "放置科研中心",
        },
	},

    {
        name = "guide-4",
		narrative = {
            {"采集P4031地质样本制造科技包..哔哩..我们就能更好地研究星球地质结构。", "textures/guide/guide-2.texture"},
            {"P4031蕴含丰富的矿藏..哔哩..先用采矿机挖掘铁矿和石矿资源..开工开工..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 20,
            task = {
                "放置采矿机",
            }
        },
        prerequisites = {
            "地质研究",
        },
	},

    {
        name = "guide-5",
		narrative = {
            {"哔哩..哔哩..矿物采集进展非常顺利，存活概率大幅提升至0.3244%！(兴奋)", "textures/guide/guide-3.texture"},
            {"哔哩..指挥中心有制造台，可以生产简单物件..请使用制造台生产几个地质科技包..哔哩(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 25,
            task = {
                "制造台生产",
            }
        },
        prerequisites = {
            "转运铁矿石",
            "挖掘碎石矿",
        },
	},

    {
        name = "guide-6",
		narrative = {
            {"组装机可使用3D打印技术制造地质科技包..哔哩..哔哗..请求建造组装机..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "放置组装机",
            }
        },
        prerequisites = {
            "制造台生产",
        },
	},

    {
        name = "guide-7",
		narrative = {
            {"科研中心针对“科技包”可开展对应的研究..哔哩..将地质科技包运送科研中心进行下一个科技研究(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            pop_chapter = {"第一阶段","科学研究"},
            guide_progress = 30,
            task = {
                "铁矿熔炼",
            }
        },
        prerequisites = {
            "自动化生产",
        },
	},

    {
        name = "guide-8",
		narrative = {
            {"哔哩..哔哗..基地开始采集气液资源，管道正是运输此类资源的关键..(兴奋)", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "生产管道",
            }
        },
        prerequisites = {
            "管道系统1",
        },
	},

    {
        name = "guide-9",
		narrative = {
            {"合理的铺设管道让基地建设更加高效...哔哩..注意管道和机器连接，那需要精细的对准(期待)", "textures/guide/guide-2.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
            }
        },
        prerequisites = {
            "生产管道",
        },
	},

    {
        name = "guide-10",
		narrative = {
            {"化工厂准备就绪，让我们正式进入化工生产..哔哩..哔哩..(兴奋）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            pop_chapter = {"第二阶段","化工生产"},
            guide_progress = 30,
            task = {
                "生产甲烷",
            }
        },
        prerequisites = {
            "维修化工厂",
        },
	},

    {
        name = "guide-11",
		narrative = {
            {"塑料可制造更多精密元件，掌握这种新材料，存活概率提升为1.2923%..哔哩(兴奋）", "textures/guide/guide-3.texture"},
        },
        narrative_end = {
            guide_progress = 30,
            task = {
                "生产塑料",
            }
        },
        prerequisites = {
            "有机化学",
        },
	},

}

return guide