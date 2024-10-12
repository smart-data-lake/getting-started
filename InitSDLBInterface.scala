import io.smartdatalake.generated._
import io.smartdatalake.lab.SmartDataLakeBuilderLab

println("Initializing SDLB Scala interface")
val sdlb = SmartDataLakeBuilderLab[DataObjectCatalog, ActionCatalog](spark,Seq("/mnt/config","/mnt/envConfig/dev.conf"), DataObjectCatalog(_, _), ActionCatalog(_, _))
implicit val context = sdlb.context
