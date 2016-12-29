since r17605;
/*
	Sweet Synthesis.ash
	Simplifies casting the sweet synthesis skill, which takes two candies and one spleen and gives a thirty-turn buff.
	
	Usage:
	synthesis [effect_wanted] - item, meat, etc.
	
	Written by Ezandora. This script is in the public domain.
*/
string __version = "1.0";

//Expensive items that are never allowed for use, as a safeguard:
//Well, I'm sure there's that totally elite in-run strategy where you use two UMSBs for +50% moxie gain, but aside from that...
boolean [item] __blacklist = $items[ultra mega sour ball,radio button candy,powdered candy sushi set,gummi ammonite,gummi trilobite,fudge bunny,chocolate cigar,vitachoconutriment capsule];


boolean [item] __simple_candy = $items[1702, 1962, 4341, 913, 1652, 2942, 3455, 3449, 3454, 3453, 3452, 3451, 4152, 1501, 5455, 5478, 5476, 5477, 1344, 5188, 4340, 1161, 912, 4342, 5454, 2941, 1346, 4192, 1494, 5456, 617, 3496, 2734, 933, 908, 3450, 1783, 2088, 2576, 907, 1767, 906, 911, 540, 263, 909, 905, 5180, 2309, 300, 2307, 298, 1163, 2306, 299, 2305, 297, 2304, 2308, 5892, 6792, 5435, 7677, 7785];
boolean [item] __complex_candy = $items[5495, 5496, 5494, 5458, 5421, 4851, 2197, 1382, 4334, 4333, 5424, 3269, 5422, 921, 5425, 5423, 3091, 2955, 5416, 5419, 5418, 5417, 5420, 5381, 5319, 5400, 4330, 4332, 5406, 5405, 4818, 5402, 5318, 5384, 4331, 5320, 5382, 5398, 5401, 5397, 5317, 5385, 5321, 5383, 3290, 3760, 2193, 5413, 5459, 5483, 3584, 5395, 5396, 5482, 4256, 5484, 2943, 4329, 3054, 4758, 4163, 4466, 4464, 4465, 4462, 4467, 4463, 4623, 5157, 4395, 4394, 4393, 4518, 5189, 4151, 5023, 3428, 3423, 3424, 5457, 3425, 5480, 5474, 5479, 5473, 5481, 5475, 4164, 3631, 4853, 5414, 5415, 3046, 5345, 1345, 5103, 2220, 4746, 4389, 3125, 4744, 4273, 3422, 1999, 3426, 4181, 4180, 4176, 4183, 4179, 4191, 4182, 4178, 4745, 5526, 6835, 6852, 6833, 6834, 6836, 7499, 7915, 8257, 7914, 6837, 8151, 3124, 8149, 8154, 7919, 6840, 5736, 6831, 7917, 8150, 6404, 6841, 6904, 6903, 7918, 7710, 6399, 9146, 8537, 6405, 6843, 7474, 6172, 9252, 5913];


//Utility:
void listAppend(item [int] list, item entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(item [int][int] list, item [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

item [int] listMake(item e1, item e2)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

//Statics:

static
{
    string [effect] __buff_descriptions;
    __buff_descriptions[$effect[Synthesis: Hot]] = "+9 hot res";
    __buff_descriptions[$effect[Synthesis: Cold]] = "+9 cold res";
    __buff_descriptions[$effect[Synthesis: Pungent]] = "+9 stench res";
    __buff_descriptions[$effect[Synthesis: Scary]] = "+9 spooky res";
    __buff_descriptions[$effect[Synthesis: Greasy]] = "+9 sleaze res";
    
    __buff_descriptions[$effect[Synthesis: Strong]] = "+300% muscle";
    __buff_descriptions[$effect[Synthesis: Smart]] = "+300% myst";
    __buff_descriptions[$effect[Synthesis: Cool]] = "+300% moxie";
    __buff_descriptions[$effect[Synthesis: Hardy]] = "+300% max HP";
    __buff_descriptions[$effect[Synthesis: Energy]] = "+300% max MP";
    
    __buff_descriptions[$effect[Synthesis: Greed]] = "+300% meat";
    __buff_descriptions[$effect[Synthesis: Collection]] = "+150% item";
    __buff_descriptions[$effect[Synthesis: Movement]] = "+50% muscle gain";
    __buff_descriptions[$effect[Synthesis: Learning]] = "+50% myst gain";
    __buff_descriptions[$effect[Synthesis: Style]] = "+50% moxie gain";
    
	int [effect] __buff_tiers;
    __buff_tiers[$effect[Synthesis: Hot]] = 1;
    __buff_tiers[$effect[Synthesis: Cold]] = 1;
    __buff_tiers[$effect[Synthesis: Pungent]] = 1;
    __buff_tiers[$effect[Synthesis: Scary]] = 1;
    __buff_tiers[$effect[Synthesis: Greasy]] = 1;
    
    __buff_tiers[$effect[Synthesis: Strong]] = 2;
    __buff_tiers[$effect[Synthesis: Smart]] = 2;
    __buff_tiers[$effect[Synthesis: Cool]] = 2;
    __buff_tiers[$effect[Synthesis: Hardy]] = 2;
    __buff_tiers[$effect[Synthesis: Energy]] = 2;
    
    __buff_tiers[$effect[Synthesis: Greed]] = 3;
    __buff_tiers[$effect[Synthesis: Collection]] = 3;
    __buff_tiers[$effect[Synthesis: Movement]] = 3;
    __buff_tiers[$effect[Synthesis: Learning]] = 3;
    __buff_tiers[$effect[Synthesis: Style]] = 3;
    
    int [effect] __buff_subid;
    __buff_subid[$effect[Synthesis: Hot]] = 1;
    __buff_subid[$effect[Synthesis: Cold]] = 2;
    __buff_subid[$effect[Synthesis: Pungent]] = 3;
    __buff_subid[$effect[Synthesis: Scary]] = 4;
    __buff_subid[$effect[Synthesis: Greasy]] = 5;
    
    __buff_subid[$effect[Synthesis: Strong]] = 1;
    __buff_subid[$effect[Synthesis: Smart]] = 2;
    __buff_subid[$effect[Synthesis: Cool]] = 3;
    __buff_subid[$effect[Synthesis: Hardy]] = 4;
    __buff_subid[$effect[Synthesis: Energy]] = 5;
    
    __buff_subid[$effect[Synthesis: Greed]] = 1;
    __buff_subid[$effect[Synthesis: Collection]] = 2;
    __buff_subid[$effect[Synthesis: Movement]] = 3;
    __buff_subid[$effect[Synthesis: Learning]] = 4;
    __buff_subid[$effect[Synthesis: Style]] = 5;
}


item [int][int] calculateSweetSynthesisCandyCombinations(int tier, int subid)
{
    item [int][int] result;
    boolean [item] candy_1;
    boolean [item] candy_2;
    
    if (tier == 1)
    {
    	candy_1 = __simple_candy;
    	candy_2 = __simple_candy;
    }
    else if (tier == 2)
    {
    	candy_1 = __simple_candy;
    	candy_2 = __complex_candy;
    }
    else if (tier == 3)
    {
    	candy_1 = __complex_candy;
    	candy_2 = __complex_candy;
    }
    foreach item_1 in candy_1
    {
        int item_1_id = item_1.to_int();
        if (__blacklist contains item_1)
        	continue;
        
        foreach item_2 in candy_2
        {
        	if (__blacklist contains item_2)
        		continue;
            int item_2_id = item_2.to_int();
            if ((item_1_id + item_2_id) % 5 != (subid - 1))
                continue;
            result.listAppend(listMake(item_1, item_2));
        }
    }
    return result;
}

int synthesis_price(item it)
{
    if (!it.tradeable)
        return 999999999;
    int price = it.historical_price();
    if (price <= 0)
        return 999999999;
    return price;
}

void main(string arguments)
{
	print("Sweet Synthesis.ash version " + __version);
	
	if (!$skill[sweet synthesis].have_skill())
	{
		print("You don't seem to have the Sweet Synthesis skill.", "red");
		return;
	}
	if (spleen_limit() - my_spleen_use() <= 0)
	{
		print("You need free spleen space to use this.", "red");
		return;
	}
	
	//Parse arguments:
	effect requested_effect;
	arguments = arguments.to_lower_case();
	if (arguments.contains_text("meat") || arguments.contains_text("greed"))
		requested_effect = $effect[Synthesis: Greed]; //+300% meat
	else if (arguments.contains_text("item") || arguments.contains_text("collection"))
		requested_effect = $effect[Synthesis: Collection]; //+150% item
	else if (arguments.contains_text("muscle gain") || arguments.contains_text("muscle exp") || arguments.contains_text("movement"))
		requested_effect = $effect[Synthesis: Movement]; //+50% muscle gain
	else if (arguments.contains_text("myst gain") || arguments.contains_text("myst exp") || arguments.contains_text("mysticality gain") || arguments.contains_text("mysticality exp") || arguments.contains_text("learning"))
		requested_effect = $effect[Synthesis: Learning]; //+50% myst gain
	else if (arguments.contains_text("moxie gain") || arguments.contains_text("moxie exp") || arguments.contains_text("style"))
		requested_effect = $effect[Synthesis: Style]; //+50% moxie gain
	else if (arguments.contains_text("muscle") || arguments.contains_text("strong"))
		requested_effect = $effect[Synthesis: Strong]; //+300% muscle
	else if (arguments.contains_text("myst") || arguments.contains_text("smart"))
		requested_effect = $effect[Synthesis: Smart]; //+300% myst
	else if (arguments.contains_text("moxie") || arguments.contains_text("cool"))
		requested_effect = $effect[Synthesis: Cool]; //+300% moxie
	else if (arguments.contains_text("hp") || arguments.contains_text("hardy"))
		requested_effect = $effect[Synthesis: Hardy]; //+300% max HP
	else if (arguments.contains_text("mp") || arguments.contains_text("energy"))
		requested_effect = $effect[Synthesis: Energy]; //+300% max MP
	else if (arguments.contains_text("hot") || arguments.contains_text("hot"))
		requested_effect = $effect[Synthesis: Hot]; //+9 hot res
	else if (arguments.contains_text("cold") || arguments.contains_text("cold"))
		requested_effect = $effect[Synthesis: Cold]; //+9 cold res
	else if (arguments.contains_text("stench") || arguments.contains_text("pungent"))
		requested_effect = $effect[Synthesis: Pungent]; //+9 stench res
	else if (arguments.contains_text("spooky") || arguments.contains_text("scary"))
		requested_effect = $effect[Synthesis: Scary]; //+9 spooky res
	else if (arguments.contains_text("sleaze") || arguments.contains_text("greasy"))
		requested_effect = $effect[Synthesis: Greasy]; //+9 sleaze res
		
	if (arguments == "" || requested_effect == $effect[none])
	{
		//Print help:
		print_html(" ");
		print_html("Sweet Synthesis.ash will give you thirty turns of a buff using candy, costing a single spleen.");
		if (can_interact())
			print_html("Outside of ronin, it will automatically acquire the cheapest candy from the mall.");
		else
			print_html("In ronin, it will use whatever candy you have in inventory, and request to confirm it.");
		print_html(" ");
		print_html("Usage: synthesis requested_effect");
		print_html("Use one of the following bolded names:");
		print_html("<b>meat</b>: +300% meat");
		print_html("<b>item</b>: +150% item");
		print_html("<b>muscle exp</b>: +50% muscle gain");
		print_html("<b>myst exp</b>: +50% mysticality gain");
		print_html("<b>moxie exp</b>: +50% moxie gain");
		print_html("<b>muscle</b>: +300% muscle");
		print_html("<b>myst</b>: +300% mysticality");
		print_html("<b>moxie</b>: +300% moxie");
		print_html("<b>HP</b>: +300% maximum HP");
		print_html("<b>MP</b>: +300% maximum MP");
		print_html("<b>hot</b>: +9 hot res");
		print_html("<b>cold</b>: +9 cold res");
		print_html("<b>stench</b>: +9 stench res");
		print_html("<b>spooky</b>: +9 spooky res");
		print_html("<b>sleaze</b>: +9 sleaze res");
		
		return;
	}
	
	//Locked into an effect, let's try it:
	print("Requested effect: " + requested_effect + " (" + __buff_descriptions[requested_effect] + ")");
	item [int][int] combinations = calculateSweetSynthesisCandyCombinations(__buff_tiers[requested_effect], __buff_subid[requested_effect]);
	//Pick cheapest combination obtainable:
	
	item final_candy_1 = $item[none];
	item final_candy_2 = $item[none];
	if (!can_interact())
	{
		//Ronin:
		item [int][int] combinations_2;
		foreach key in combinations
		{
			item item_1 = combinations[key][0];
			item item_2 = combinations[key][1];
			if (item_1.item_amount() == 0 || item_2.item_amount() == 0)
				continue;
			combinations_2.listAppend(listMake(item_1, item_2));
		}
		sort combinations_2 by value[0].synthesis_price() + value[1].synthesis_price();
		item [int][int] final_combinations;
		foreach key in combinations_2
		{
			if (key > 4)
				break;
			final_combinations.listAppend(combinations_2[key]);
		}
		sort final_combinations by value[0].mall_price() + value[1].mall_price();
		final_candy_1 = final_combinations[0][0];
		final_candy_2 = final_combinations[0][1];
		boolean yes = user_confirm("Allow consuming " + final_candy_1 + " + " + final_candy_2 + "?");
		if (!yes)
		{
			print("Canceled.");
			return;
		}
	}
	else
	{
		//Mall access:
		sort combinations by (value[0].synthesis_price() + value[1].synthesis_price());
		//Take first five, sort by mall price:
		item [int][int] final_combinations;
		foreach key in combinations
		{
			if (key > 4)
				break;
			final_combinations.listAppend(combinations[key]);
		}
		sort final_combinations by value[0].mall_price() + value[1].mall_price();
		if (final_combinations.count() == 0)
		{
			print("Umm... no candy? Nooooo....", "red");
			return;
		}
		final_candy_1 = final_combinations[0][0];
		final_candy_2 = final_combinations[0][1];
	}
	
	if (final_candy_1 == $item[none] || final_candy_2 == $item[none])
	{
		print("Internal error, sorry.", "red");
		return;
	}
	int mall_price_limit = 100000;
	if (can_interact())
		mall_price_limit = 20000;
		
	int [item] required_items;
	required_items[final_candy_1] += 1;
	required_items[final_candy_2] += 1;
	foreach it, amount in required_items
	{
		if (it.item_amount() < amount)
		{
			if (can_interact())
			{
				if (!get_property("autoSatisfyWithMall").to_boolean())
				{
					int breakout = 2;
					while (breakout > 0 && it.item_amount() < amount)
					{
						breakout -= 1;
						buy(1, it, MIN(20000, mall_price_limit)); //the single most dangerous command mafia can ever use
					}
				}
				else
					retrieve_item(MIN(2, amount), it);
			}
			else
			{
				print("Can't acquire this candy.", "red");
				return;
			}
		}
	}
	
	print("Chosen candy: " + final_candy_1 + " + " + final_candy_2);
	if (final_candy_1.item_amount() == 0 || final_candy_2.item_amount() == 0)
	{
		print("Can't acquire the candy for some reason.", "red");
		return;
	}
	if (final_candy_1.mall_price() >= mall_price_limit || final_candy_2.mall_price() >= mall_price_limit) //failsafe
	{
		print("This candy is too expensive, bailing out.", "red");
		return;
	}
	if (__blacklist contains final_candy_1 || __blacklist contains final_candy_2) //shouldn't show up
	{
		print("Blacklisted candy! No can do.", "red");
		return;
	}
	
	visit_url("runskillz.php?action=Skillz&whichskill=166&targetplayer=" + my_id() + "&quantity=1");
	visit_url("choice.php?a=" + final_candy_1.to_int() + "&b=" + final_candy_2.to_int() + "&whichchoice=1217&option=1");
	cli_execute("refresh inventory"); //TEMPORARY; mafia will track properly eventually
}