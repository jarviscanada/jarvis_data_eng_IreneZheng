package ca.jrvs.apps.practice;

import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class LambdaStreamMain {

    public static void main(String[] args) {
        LambdaStreamExc lse = new LambdaStreamImp();

        // Test 1: toUpperCase
        System.out.println("=== toUpperCase ===");
        lse.toUpperCase("hello", "world")
                .forEach(System.out::println);

        // Test 2: filter
        System.out.println("=== filter ===");
        Stream<String> stream = Stream.of("apple", "cat", "dog");
        lse.filter(stream, "a")
                .forEach(System.out::println);

        // Test 3: createIntStream
        System.out.println("=== createIntStream ===");
        lse.createIntStream(1, 5)
                .forEach(System.out::println);

        // Test 4: squareRoot
        System.out.println("=== squareRoot ===");
        lse.squareRootIntStream(IntStream.of(4, 9, 16))
                .forEach(System.out::println);

        // Test 5: printOdd
        System.out.println("=== printOdd ===");
        lse.printOdd(
                IntStream.rangeClosed(1, 10),
                lse.getLambdaPrinter("odd:", "!")
        );

        // Test 6: flatNestedInt
        System.out.println("=== flatNestedInt ===");
        Stream<List<Integer>> nested = Stream.of(
                Arrays.asList(1, 2),
                Arrays.asList(3, 4)
        );
        lse.flatNestedInt(nested)
                .forEach(System.out::println);
    }
}
