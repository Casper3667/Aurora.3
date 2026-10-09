/**
 * Loads the last saved stock into vending machines which were part of the initial Horizon map load.
 * The machine keeps its original ID if moved, so only stock and never its position is persisted.
 */
/datum/controller/subsystem/persistence/proc/vendingStockInitialize()
	vending_stock_register = list()
	var/datum/persistent_generic/saved_stock = genericLoad(/singleton/persistent_type/generic/horizon_vending_stock)
	var/list/all_saved_stock = saved_stock?.content

	for(var/obj/structure/machinery/vending/vendor as anything in SSmachinery.machinery)
		CHECK_TICK
		if(!vendor.persistent_stock_id)
			continue
		vending_stock_register += vendor

		var/list/vendor_stock = all_saved_stock?[vendor.persistent_stock_id]
		if(!islist(vendor_stock))
			continue

		for(var/datum/data/vending_product/product in vendor.product_records)
			if(product.category != CAT_NORMAL)
				continue
			var/stock_key = "[product.product_path]|[product.category]"
			var/saved_amount = vendor_stock[stock_key]
			if(isnum(saved_amount))
				product.amount = clamp(saved_amount, 0, product.max_amount)

/** Saves stock for the initially mapped vendors without considering their current locations. */
/datum/controller/subsystem/persistence/proc/vendingStockFinalize()
	var/list/all_stock = list()
	for(var/obj/structure/machinery/vending/vendor as anything in vending_stock_register)
		CHECK_TICK
		if(QDELETED(vendor))
			continue

		var/list/vendor_stock = list()
		for(var/datum/data/vending_product/product in vendor.product_records)
			if(product.category != CAT_NORMAL)
				continue
			var/stock_key = "[product.product_path]|[product.category]"
			vendor_stock[stock_key] = product.amount
		all_stock[vendor.persistent_stock_id] = vendor_stock

	genericSave(/singleton/persistent_type/generic/horizon_vending_stock, all_stock)

/singleton/persistent_type/generic/horizon_vending_stock/finalization_hook()
	SSpersistence.vendingStockFinalize()
