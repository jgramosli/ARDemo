using System;
using System.Collections.Generic;
using System.Linq;

namespace Tech.General
{
    public static class Rand
    {
        static readonly Random _rand = new Random();

        public static int NextInt()
        {
            return _rand.Next();
        }

        /// <summary>
        /// Returns a non-negative random number less than the specified amount
        /// </summary>
        /// <param name="maxExclusive"></param>
        /// <returns></returns>
        public static int NextInt(int maxExclusive)
        {
            return _rand.Next(maxExclusive);
        }

        public static int NextInt(int minInclusive, int maxExclusive)
        {
            return _rand.Next(maxExclusive - minInclusive) + minInclusive;
        }

        /// <summary>
        /// Returns a non-negative random number between 0.0 and 1.0 (inclusive)
        /// </summary>
        /// <returns></returns>
        public static float NextFloat()
        {
            return (float)_rand.NextDouble();
        }

        /// <summary>
        /// Returns a non-negative random number less than or equal to the specified amount
        /// </summary>
        /// <param name="maxExclusive"></param>
        /// <returns></returns>
        public static float NextFloat(float maxExclusive)
        {
            return NextFloat() * maxExclusive;
        }

        public static float NextFloat(float minInclusive, float maxExclusive)
        {
            return NextFloat(maxExclusive - minInclusive) + minInclusive;
        }

        public static bool NextBool(float chance = 0.5f)
        {
            return NextFloat() < chance;
        }

        /// <summary>
        /// Return an item randomly selected from list, ignoring any items that are present in the optional exclude list
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="items"></param>
        /// <param name="exclude"></param>
        /// <returns></returns>
        public static T RandomItem<T>(this IEnumerable<T> items, List<T> exclude = null)
        {
            var allowedItems = new List<T>(items);

            if (exclude != null)
            {
                for( int i = 0; i < exclude.Count; i++ )
                {
                    allowedItems.Remove(exclude[i]);
                }
            }

            return allowedItems[NextInt(allowedItems.Count)];
        }

        public static T RandomItem<T>(this IEnumerable<T> items, params T[] exclude)
        {
            var allowedItems = new List<T>(items);

            foreach (var itemToExclude in exclude)
            {
                allowedItems.Remove(itemToExclude);
            }

            return allowedItems[NextInt(allowedItems.Count)];
        }

        public static T RandomItem<T>(this List<T> items)
        {
            return items[NextInt(items.Count)];
        }

        public static T PopRandom<T>(this List<T> items)
        {
            var item = items.RandomItem();
            items.Remove(item);

            return item;
        }

        /// <summary>
        /// Randomizes the order of all of the items in the supplied list
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="list"></param>
        public static void RandomizeOrder<T>(this List<T> list)
        {
            var list2 = new List<T>(list);
            list.Clear();

            while (list2.Count > 0)
            {
                var item = RandomItem(list2);
                list2.Remove(item);
                list.Add(item);
            }
        }
    }
}