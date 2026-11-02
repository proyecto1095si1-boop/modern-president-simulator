class_name Trade
extends RefCounted

## Simple resource trade between player and target nation.

static func can_trade(buyer: Country, seller: Country) -> bool:
	if not buyer or not seller:
		return false
	if seller.id in buyer.diplomacy.at_war_with:
		return false
	if seller.id in buyer.diplomacy.embargos:
		return false
	return true

## Buy oil from target (pays gold/treasury)
static func buy_oil(buyer: Country, seller: Country, amount: float = 15.0) -> String:
	if not can_trade(buyer, seller):
		return "Cannot trade (war/embargo)"
	var price = amount * 0.8
	if buyer.economy.treasury < price:
		return "Not enough treasury"
	if seller.economy.oil < amount * 0.5:
		return "Seller has little oil"
	buyer.economy.treasury -= price
	seller.economy.treasury += price * 0.85
	buyer.economy.oil += amount
	seller.economy.oil = maxf(seller.economy.oil - amount * 0.4, 0.0)
	buyer.diplomacy.improve_relation(seller.id, 2.0)
	return "Bought %.0f oil for %.1f B" % [amount, price]

static func buy_food(buyer: Country, seller: Country, amount: float = 20.0) -> String:
	if not can_trade(buyer, seller):
		return "Cannot trade"
	var price = amount * 0.5
	if buyer.economy.treasury < price:
		return "Not enough treasury"
	buyer.economy.treasury -= price
	seller.economy.treasury += price * 0.8
	buyer.economy.food += amount
	buyer.diplomacy.improve_relation(seller.id, 1.5)
	return "Bought %.0f food for %.1f B" % [amount, price]

static func sell_iron(seller: Country, buyer: Country, amount: float = 12.0) -> String:
	if not can_trade(seller, buyer):
		return "Cannot trade"
	if seller.economy.iron < amount:
		return "Not enough iron"
	var price = amount * 0.9
	seller.economy.iron -= amount
	seller.economy.treasury += price
	buyer.economy.iron += amount * 0.9
	seller.diplomacy.improve_relation(buyer.id, 2.0)
	return "Sold %.0f iron for %.1f B" % [amount, price]
