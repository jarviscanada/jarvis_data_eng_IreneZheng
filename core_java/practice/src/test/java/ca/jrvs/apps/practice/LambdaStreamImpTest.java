package ca.jrvs.apps.practice;

import org.junit.Test;
import static org.junit.Assert.*;

import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;
import java.util.stream.Stream;
import java.util.stream.Collectors;

public class LambdaStreamImpTest {

    private final LambdaStreamImp lsi = new LambdaStreamImp();

    @Test
    public void testCreateStrStream() {
        Stream<String> stream = lsi.createStrStream("a", "b", "c");
        List<String> result = stream.collect(Collectors.toList());
        assertEquals(Arrays.asList("a", "b", "c"), result);
    }

    @Test
    public void testToUpperCase() {
        Stream<String> stream = lsi.toUpperCase("hello", "world");
        List<String> result = stream.collect(Collectors.toList());
        assertEquals(Arrays.asList("HELLO", "WORLD"), result);
    }

    @Test
    public void testFilter() {
        Stream<String> stream = lsi.createStrStream("cat", "dog", "apple");
        Stream<String> filtered = lsi.filter(stream, "a");
        List<String> result = filtered.collect(Collectors.toList());
        assertEquals(Arrays.asList("dog"), result);
    }

    @Test
    public void testCreateIntStream() {
        IntStream is = lsi.createIntStream(new int[]{1, 2, 3});
        assertArrayEquals(new int[]{1, 2, 3}, is.toArray());
    }

    @Test
    public void testGetOdd() {
        IntStream is = lsi.getOdd(IntStream.rangeClosed(1, 5));
        assertArrayEquals(new int[]{1, 3, 5}, is.toArray());
    }

    @Test
    public void testSquareRootIntStream() {
        double[] actual = lsi.squareRootIntStream(IntStream.of(4, 9, 16)).toArray();
        assertArrayEquals(new double[]{2.0, 3.0, 4.0}, actual, 0.0001);
    }

    @Test
    public void testFlatNestedInt() {
        Stream<List<Integer>> nested = Stream.of(
                Arrays.asList(1, 2),
                Arrays.asList(3, 4)
        );
        List<Integer> result = lsi.flatNestedInt(nested).collect(Collectors.toList());
        assertEquals(Arrays.asList(1, 2, 3, 4), result);
    }
}
