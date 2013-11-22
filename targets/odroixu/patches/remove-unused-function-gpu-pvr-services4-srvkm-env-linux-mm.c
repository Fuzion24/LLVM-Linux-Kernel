diff --git a/drivers/gpu/pvr/services4/srvkm/env/linux/mm.c b/drivers/gpu/pvr/services4/srvkm/env/linux/mm.c
index 71ef320..3f7f911 100644
--- a/drivers/gpu/pvr/services4/srvkm/env/linux/mm.c
+++ b/drivers/gpu/pvr/services4/srvkm/env/linux/mm.c
@@ -741,12 +741,6 @@ static inline void
 PagePoolUnlock(void)
 {
 }
-
-static inline int
-PagePoolTrylock(void)
-{
-	return 1;
-}
 #endif	/* (PVR_LINUX_MEM_AREA_POOL_MAX_PAGES != 0) */
 
 
