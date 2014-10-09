import java.util.ArrayList;ddd
import si.fri.algotest.entities.ETestSet;
import si.fri.algotest.entities.ParameterSet;
import si.fri.algotest.execute.Executor;
import si.fri.algotest.tools.ATTools;

/**
 *
 * @author tomaz
 */
public class BubblesortSortAlgorithm extends SortAbsAlgorithm {

  public void execute(int[] data) {
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data.length; j++) {
	if (data[i] > data[j]) {
	  int tmp = data[i];
	  data[i]=data[j];
	  data[j]=data[i];
	}
      }
    }
  }
  
  public static void main(String args[]) {
    String root         = "/Users/tomaz/delo/AlgoTest/projects";
    String projName     = "Sorting";
    
    ETestSet testSet = ATTools.getFirstTestSetFromProject(root, projName);
    SortTestSetIterator stsi = new SortTestSetIterator();
    stsi.setTestSet(testSet);
    ArrayList<ParameterSet> results = 
	    Executor.iterateAndRunAlgorithm(new BubblesortSortAlgorithm(), stsi, null,  null);
    for(ParameterSet param : results)
      System.out.println(param);
  }
}
