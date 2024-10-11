import io.smartdatalake.generated._
import io.smartdatalake.lab.SmartDataLakeBuilderLab
val sdlb = SmartDataLakeBuilderLab[DataObjectCatalog, ActionCatalog](spark,Seq("/mnt/config"), DataObjectCatalog(_, _), ActionCatalog(_, _))
implicit val context = sdlb.context