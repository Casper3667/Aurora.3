/datum/persistent_vending_stock
	/// The initially mapped vendor. Its current location is deliberately irrelevant.
	var/obj/structure/machinery/vending/vendor

/** Returns current stock, or null when the vendor no longer exists so its prior generic is left untouched. */
/datum/persistent_vending_stock/proc/get_final_stock()
	if(QDELETED(vendor))
		return

	var/list/vendor_stock = list()
	for(var/datum/data/vending_product/product in vendor.product_records)
		// Premium items and contraband are not part of normal persistent stock.
		if(product.category != CAT_NORMAL)
			continue
		var/stock_key = "[product.product_path]|[product.category]"
		vendor_stock[stock_key] = product.amount
	return vendor_stock

/singleton/persistent_type/generic/horizon_vending_stock
	/// Persistent vending machines present on the Horizon, keyed by their generic attribute.
	var/list/vending_stock_register = list()
	/// Whether initialization completed successfully. Prevents a failed load from overwriting saved stock.
	var/stock_initialized = FALSE

/** Loads saved stock and supplies it to mapped vendors for application during late initialization. */
/singleton/persistent_type/generic/horizon_vending_stock/initialization_hook()
	vending_stock_register = list()
	stock_initialized = FALSE
	if(!SSpersistence.map_supports_persistence)
		return

	for(var/obj/structure/machinery/vending/vendor in world)
		CHECK_TICK
		var/turf/vendor_turf = get_turf(vendor)
		if(!vendor_turf || !is_station_level(vendor_turf.z) || !vendor.persistent_stock)
			continue

		var/persistent_stock_id = "[vendor.type]-[vendor_turf.x]-[vendor_turf.y]-[vendor_turf.z]"
		vendor.persistent_stock_id = persistent_stock_id
		var/datum/persistent_vending_stock/stock_record = new
		stock_record.vendor = vendor
		if(vending_stock_register[persistent_stock_id])
			log_subsystem_persistence_error("Duplicate persistent vending attribute '[persistent_stock_id]' at [vendor_turf].")
			continue
		vending_stock_register[persistent_stock_id] = stock_record

	var/list/saved_attributes = SSpersistence.genericGetAllAttributesForType(/singleton/persistent_type/generic/horizon_vending_stock)
	for(var/persistent_stock_id in saved_attributes)
		CHECK_TICK
		if(!length(persistent_stock_id))
			continue
		var/datum/persistent_vending_stock/stock_record = vending_stock_register[persistent_stock_id]
		if(!stock_record)
			continue
		var/datum/persistent_generic/saved_generic = SSpersistence.genericLoad(/singleton/persistent_type/generic/horizon_vending_stock, persistent_stock_id, skip_caching = TRUE)
		var/list/vendor_stock = saved_generic?.content
		if(!islist(vendor_stock))
			continue
		stock_record.vendor.persistent_stock_content = vendor_stock
	stock_initialized = TRUE

/** Saves stock for the initially mapped vendors without considering their current locations. */
/singleton/persistent_type/generic/horizon_vending_stock/finalization_hook()
	if(!stock_initialized)
		return

	for(var/persistent_stock_id in vending_stock_register)
		CHECK_TICK
		var/datum/persistent_vending_stock/stock_record = vending_stock_register[persistent_stock_id]
		var/list/vendor_stock = stock_record.get_final_stock()
		if(islist(vendor_stock))
			SSpersistence.genericSave(/singleton/persistent_type/generic/horizon_vending_stock, vendor_stock, persistent_stock_id, expires_in_days = 7)
